using HomeFix.BLL.Services;
using HomeFix.DAL;
using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Enums;
using HomeFix.DAL.Repositories;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace HomeFix.Tests;

public class ServiceRequestOfferConcurrencyTests
{
    private static string ConnectionString => Environment.GetEnvironmentVariable("HOMEFIX_TEST_CONNECTION_STRING") ?? string.Empty;

    [SkippableFact]
    public async Task CancelAndCreateOfferRace_LeavesRequestAndOfferConsistent()
    {
        var ids = await CreateScenarioAsync();
        try
        {
            var createTask = Task.Run(async () =>
            {
                await using var scope = await CreateServiceScopeAsync();
                return await scope.OfferService.CreateAsync(ids.RequestId, ids.TechnicianId, 250m, "race create");
            });

            var cancelTask = Task.Run(async () =>
            {
                await using var scope = await CreateServiceScopeAsync();
                return await scope.Service.CancelAsync(ids.RequestId, ids.CustomerProfileId);
            });

            await Task.WhenAll(createTask, cancelTask);
            var create = await createTask;
            var cancel = await cancelTask;

            await using var verify = await CreateContextAsync();
            var request = await verify.ServiceRequests.SingleAsync(x => x.Id == ids.RequestId);
            var offers = await verify.ServiceRequestOffers.Where(x => x.ServiceRequestId == ids.RequestId).ToListAsync();
            var booking = await verify.Bookings.SingleOrDefaultAsync(x => x.ServiceRequestId == ids.RequestId);

            Assert.False(request.Status == "Cancelled" && booking != null);
            Assert.False(request.Status == "Cancelled" && offers.Any(x => x.Status == "Accepted"));

            if (cancel.Success)
            {
                Assert.False(create.Success);
                Assert.Equal("Cancelled", request.Status);
                Assert.Empty(offers);
                Assert.Null(booking);
            }
            else
            {
                Assert.True(create.Success);
                Assert.Equal("OfferPending", request.Status);
                Assert.Single(offers);
                Assert.All(offers, x => Assert.Equal("Pending", x.Status));
                Assert.Null(booking);
            }
        }
        finally
        {
            await CleanupAsync(ids);
        }
    }

    [SkippableFact]
    public async Task CancelAndAcceptOfferRace_LeavesRequestAndBookingConsistent()
    {
        var ids = await CreateScenarioAsync();
        try
        {
            var offer = await CreatePendingOfferAsync(ids);

            var acceptTask = Task.Run(async () =>
            {
                await using var scope = await CreateServiceScopeAsync();
                return await scope.OfferService.AcceptAsync(offer.Id, ids.CustomerUserId);
            });

            var cancelTask = Task.Run(async () =>
            {
                await using var scope = await CreateServiceScopeAsync();
                return await scope.Service.CancelAsync(ids.RequestId, ids.CustomerProfileId);
            });

            await Task.WhenAll(acceptTask, cancelTask);
            var accept = await acceptTask;
            var cancel = await cancelTask;

            await using var verify = await CreateContextAsync();
            var request = await verify.ServiceRequests.SingleAsync(x => x.Id == ids.RequestId);
            var acceptedOffers = await verify.ServiceRequestOffers.Where(x => x.ServiceRequestId == ids.RequestId && x.Status == "Accepted").ToListAsync();
            var booking = await verify.Bookings.SingleOrDefaultAsync(x => x.ServiceRequestId == ids.RequestId);

            Assert.False(request.Status == "Cancelled" && booking != null);
            Assert.False(request.Status == "Cancelled" && acceptedOffers.Count > 0);

            if (accept.Success)
            {
                Assert.False(cancel.Success);
                Assert.Equal("Accepted", request.Status);
                Assert.Single(acceptedOffers);
                Assert.NotNull(booking);
                Assert.Equal(offer.Id, acceptedOffers[0].Id);
            }
            else
            {
                Assert.True(cancel.Success);
                Assert.Equal("Cancelled", request.Status);
                Assert.Empty(acceptedOffers);
                Assert.Null(booking);
            }
        }
        finally
        {
            await CleanupAsync(ids);
        }
    }

    [SkippableFact]
    public async Task AcceptAfterCancellation_IsRejectedAndCreatesNoBooking()
    {
        var ids = await CreateScenarioAsync();
        try
        {
            var offer = await CreatePendingOfferAsync(ids);
            await using (var scope = await CreateServiceScopeAsync())
            {
                var cancel = await scope.Service.CancelAsync(ids.RequestId, ids.CustomerProfileId);
                Assert.True(cancel.Success);
            }

            await using (var scope = await CreateServiceScopeAsync())
            {
                var result = await scope.OfferService.AcceptAsync(offer.Id, ids.CustomerUserId);
                Assert.False(result.Success);
                Assert.Contains("no longer accepting offers", result.Error ?? string.Empty, StringComparison.OrdinalIgnoreCase);
            }

            await using var verify = await CreateContextAsync();
            Assert.Equal("Cancelled", await verify.ServiceRequests.Where(x => x.Id == ids.RequestId).Select(x => x.Status).SingleAsync());
            Assert.Null(await verify.Bookings.SingleOrDefaultAsync(x => x.ServiceRequestId == ids.RequestId));
            Assert.Empty(await verify.ServiceRequestOffers.Where(x => x.ServiceRequestId == ids.RequestId && x.Status == "Accepted").ToListAsync());
        }
        finally
        {
            await CleanupAsync(ids);
        }
    }

    [SkippableFact]
    public async Task CancelAfterAcceptance_IsRejectedAndBookingRemainsConfirmed()
    {
        var ids = await CreateScenarioAsync();
        try
        {
            var offer = await CreatePendingOfferAsync(ids);
            await using (var scope = await CreateServiceScopeAsync())
            {
                var accepted = await scope.OfferService.AcceptAsync(offer.Id, ids.CustomerUserId);
                Assert.True(accepted.Success);
            }

            await using (var scope = await CreateServiceScopeAsync())
            {
                var result = await scope.Service.CancelAsync(ids.RequestId, ids.CustomerProfileId);
                Assert.False(result.Success);
                Assert.Equal("Only an open request can be cancelled.", result.Error);
            }

            await using var verify = await CreateContextAsync();
            Assert.Equal("Accepted", await verify.ServiceRequests.Where(x => x.Id == ids.RequestId).Select(x => x.Status).SingleAsync());
            var booking = await verify.Bookings.SingleAsync(x => x.ServiceRequestId == ids.RequestId);
            Assert.Equal("Confirmed", booking.Status);
        }
        finally
        {
            await CleanupAsync(ids);
        }
    }

    [SkippableFact]
    public async Task CancelledRequest_CannotProduceConfirmedBooking()
    {
        var ids = await CreateScenarioAsync();
        try
        {
            await using (var scope = await CreateServiceScopeAsync())
            {
                var cancel = await scope.Service.CancelAsync(ids.RequestId, ids.CustomerProfileId);
                Assert.True(cancel.Success);
            }

            await using (var scope = await CreateServiceScopeAsync())
            {
                var create = await scope.OfferService.CreateAsync(ids.RequestId, ids.TechnicianId, 250m, "after cancel");
                Assert.False(create.Success);
            }

            await using var verify = await CreateContextAsync();
            Assert.Equal("Cancelled", await verify.ServiceRequests.Where(x => x.Id == ids.RequestId).Select(x => x.Status).SingleAsync());
            Assert.Null(await verify.Bookings.SingleOrDefaultAsync(x => x.ServiceRequestId == ids.RequestId));
            Assert.Empty(await verify.ServiceRequestOffers.Where(x => x.ServiceRequestId == ids.RequestId).ToListAsync());
        }
        finally
        {
            await CleanupAsync(ids);
        }
    }

    [SkippableFact]
    public async Task RejectAndAcceptRace_LeavesOfferAndBookingConsistent()
    {
        var ids = await CreateScenarioAsync();
        try
        {
            var offer = await CreatePendingOfferAsync(ids);

            var acceptTask = Task.Run(async () =>
            {
                await using var scope = await CreateServiceScopeAsync();
                return await scope.OfferService.AcceptAsync(offer.Id, ids.CustomerUserId);
            });

            var rejectTask = Task.Run(async () =>
            {
                await using var scope = await CreateServiceScopeAsync();
                return await scope.OfferService.RejectAsync(offer.Id, ids.CustomerUserId);
            });

            var results = await Task.WhenAll(acceptTask, rejectTask);
            var accept = results[0];
            var reject = results[1];

            await using var verify = await CreateContextAsync();
            var request = await verify.ServiceRequests.SingleAsync(x => x.Id == ids.RequestId);
            var finalOffer = await verify.ServiceRequestOffers.SingleAsync(x => x.Id == offer.Id);
            var booking = await verify.Bookings.SingleOrDefaultAsync(x => x.ServiceRequestId == ids.RequestId);

            Assert.Contains(finalOffer.Status, new[] { "Accepted", "Rejected" });
            if (accept.Success)
            {
                Assert.False(reject.Success);
                Assert.Equal("Accepted", finalOffer.Status);
                Assert.Equal("Accepted", request.Status);
                Assert.NotNull(booking);
            }
            else
            {
                Assert.True(reject.Success);
                Assert.Equal("Rejected", finalOffer.Status);
                Assert.Equal("OfferPending", request.Status);
                Assert.Null(booking);
            }
        }
        finally
        {
            await CleanupAsync(ids);
        }
    }

    [SkippableFact]
    public async Task NormalCancellation_StillWorks()
    {
        var ids = await CreateScenarioAsync();
        try
        {
            await using var scope = await CreateServiceScopeAsync();
            var result = await scope.Service.CancelAsync(ids.RequestId, ids.CustomerProfileId);
            Assert.True(result.Success);
            Assert.Equal("Cancelled", result.Request?.Status);
        }
        finally
        {
            await CleanupAsync(ids);
        }
    }

    [SkippableFact]
    public async Task NormalOfferCreation_StillWorks()
    {
        var ids = await CreateScenarioAsync();
        try
        {
            await using var scope = await CreateServiceScopeAsync();
            var result = await scope.OfferService.CreateAsync(ids.RequestId, ids.TechnicianId, 250m, "valid offer");
            Assert.True(result.Success);
            Assert.NotNull(result.Offer);

            await using var verify = await CreateContextAsync();
            Assert.Equal("OfferPending", await verify.ServiceRequests.Where(x => x.Id == ids.RequestId).Select(x => x.Status).SingleAsync());
            Assert.Equal("Pending", await verify.ServiceRequestOffers.Where(x => x.Id == result.Offer!.Id).Select(x => x.Status).SingleAsync());
        }
        finally
        {
            await CleanupAsync(ids);
        }
    }

    [SkippableFact]
    public async Task NormalOfferAcceptance_StillCreatesConfirmedBooking()
    {
        var ids = await CreateScenarioAsync();
        try
        {
            var offer = await CreatePendingOfferAsync(ids);
            await using var scope = await CreateServiceScopeAsync();
            var result = await scope.OfferService.AcceptAsync(offer.Id, ids.CustomerUserId);
            Assert.True(result.Success);

            await using var verify = await CreateContextAsync();
            Assert.Equal("Accepted", await verify.ServiceRequests.Where(x => x.Id == ids.RequestId).Select(x => x.Status).SingleAsync());
            var savedOffer = await verify.ServiceRequestOffers.SingleAsync(x => x.Id == offer.Id);
            Assert.Equal("Accepted", savedOffer.Status);
            Assert.NotNull(await verify.Bookings.SingleOrDefaultAsync(x => x.ServiceRequestId == ids.RequestId));
        }
        finally
        {
            await CleanupAsync(ids);
        }
    }

    private static async Task<ServiceRequestTestIds> CreateScenarioAsync()
    {
        await EnsureDatabaseAvailableAsync();
        await using var db = await CreateContextAsync();

        var technician = await db.TechnicianProfiles
            .Include(x => x.Services)
            .Include(x => x.TechnicianServiceAreas)
            .Include(x => x.User)
            .Where(x => x.IsVerified && x.IsAvailable && x.User.IsActive)
            .FirstOrDefaultAsync(x =>
                x.Services.Any(s => s.IsActive && s.PricingMode != PricingMode.Inspection) &&
                x.TechnicianServiceAreas.Any(a => db.Addresses.Any(ad => ad.CityId == a.CityId)));

        if (technician == null)
        {
            Skip.If(true, "No verified/available technician with a matching test service area was found.");
            throw new InvalidOperationException("No verified/available technician with a matching test service area was found.");
        }

        var service = technician.Services.First(x => x.IsActive && x.PricingMode != PricingMode.Inspection);
        var cityId = technician.TechnicianServiceAreas.Select(x => x.CityId).First(x => db.Addresses.Any(a => a.CityId == x));
        var address = await db.Addresses.FirstAsync(x => x.CityId == cityId);
        var customer = await db.CustomerProfiles.Include(x => x.User).SingleAsync(x => x.Id == address.CustomerId);

        var request = new ServiceRequest
        {
            CustomerId = customer.Id,
            ServiceId = service.Id,
            AddressId = address.Id,
            Description = "Concurrency regression test",
            Status = "Open",
            VisitFee = 1m,
            CreatedAt = DateTime.UtcNow
        };
        db.ServiceRequests.Add(request);
        await db.SaveChangesAsync();

        return new ServiceRequestTestIds(request.Id, technician.Id, customer.Id, customer.UserId);
    }

    private static async Task<ServiceRequestOffer> CreatePendingOfferAsync(ServiceRequestTestIds ids)
    {
        await using var scope = await CreateServiceScopeAsync();
        var result = await scope.OfferService.CreateAsync(ids.RequestId, ids.TechnicianId, 250m, "seed offer");
        Assert.True(result.Success);
        return result.Offer!;
    }

    private static async Task<TestServiceScope> CreateServiceScopeAsync()
    {
        var context = await CreateContextAsync();
        var requestRepo = new ServiceRequestRepository(context);
        var offerRepo = new ServiceRequestOfferRepository(context);
        var bookingRepo = new BookingRepository(context);
        var technicianRepo = new TechnicianProfileRepository(context);
        var unitOfWork = new UnitOfWork(context);
        return new TestServiceScope(
            context,
            new ServiceRequestService(requestRepo, unitOfWork),
            new ServiceRequestOfferService(offerRepo, requestRepo, bookingRepo, technicianRepo, unitOfWork));
    }

    private static async Task<HomeFixDbContext> CreateContextAsync()
    {
        await EnsureDatabaseAvailableAsync(skipIfMissing: false);
        var options = new DbContextOptionsBuilder<HomeFixDbContext>()
            .UseSqlServer(ConnectionString, sql => sql.EnableRetryOnFailure())
            .Options;
        return new HomeFixDbContext(options);
    }

    private static async Task EnsureDatabaseAvailableAsync(bool skipIfMissing = true)
    {
        if (string.IsNullOrWhiteSpace(ConnectionString))
        {
            if (skipIfMissing)
            {
                Skip.If(true, "Set HOMEFIX_TEST_CONNECTION_STRING to run SQL Server concurrency tests.");
            }
            throw new InvalidOperationException("Set HOMEFIX_TEST_CONNECTION_STRING to run SQL Server concurrency tests.");
        }

        var options = new DbContextOptionsBuilder<HomeFixDbContext>()
            .UseSqlServer(ConnectionString, sql => sql.EnableRetryOnFailure())
            .Options;
        await using var db = new HomeFixDbContext(options);
        if (!await db.Database.CanConnectAsync())
        {
            if (skipIfMissing)
            {
                Skip.If(true, "HOMEFIX_TEST_CONNECTION_STRING could not connect to SQL Server.");
            }
            throw new InvalidOperationException("HOMEFIX_TEST_CONNECTION_STRING could not connect to SQL Server.");
        }
    }

    private static async Task CleanupAsync(ServiceRequestTestIds ids)
    {
        await using var db = await CreateContextAsync();
        var offers = await db.ServiceRequestOffers.Where(x => x.ServiceRequestId == ids.RequestId).ToListAsync();
        var booking = await db.Bookings.SingleOrDefaultAsync(x => x.ServiceRequestId == ids.RequestId);
        if (booking != null) db.Bookings.Remove(booking);
        db.ServiceRequestOffers.RemoveRange(offers);
        var request = await db.ServiceRequests.SingleOrDefaultAsync(x => x.Id == ids.RequestId);
        if (request != null) db.ServiceRequests.Remove(request);
        await db.SaveChangesAsync();
    }

    private sealed record ServiceRequestTestIds(int RequestId, int TechnicianId, int CustomerProfileId, int CustomerUserId);

    private sealed class TestServiceScope : IAsyncDisposable
    {
        public HomeFixDbContext Context { get; }
        public ServiceRequestService Service { get; }
        public ServiceRequestOfferService OfferService { get; }

        public TestServiceScope(HomeFixDbContext context, ServiceRequestService service, ServiceRequestOfferService offerService)
        {
            Context = context;
            Service = service;
            OfferService = offerService;
        }

        public ValueTask DisposeAsync() => Context.DisposeAsync();
    }
}
