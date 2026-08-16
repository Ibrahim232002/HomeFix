using System.Security.Claims;
using HomeFix.API.DTOs.ServiceRequestOffer;
using HomeFix.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ServiceRequestOffersController : ControllerBase
{
    private readonly IServiceRequestOfferService _service;
    private readonly IServiceRequestService _requests;
    private readonly ICustomerProfileService _customerProfiles;
    private readonly ITechnicianProfileService _technicianProfiles;

    public ServiceRequestOffersController(IServiceRequestOfferService service, IServiceRequestService requests, ICustomerProfileService customerProfiles, ITechnicianProfileService technicianProfiles)
    { _service = service; _requests = requests; _customerProfiles = customerProfiles; _technicianProfiles = technicianProfiles; }

    [HttpGet("request/{requestId:int}")]
    public async Task<IActionResult> GetByRequest(int requestId)
    {
        var request = await _requests.GetByIdAsync(requestId);
        if (request == null) return NotFound();
        if (!await CanAccessRequestAsync(request)) return Forbid();
        return Ok((await _service.GetByRequestIdAsync(requestId)).Select(Map));
    }

    [HttpGet("mine")]
    [Authorize(Roles = "Technician")]
    public async Task<IActionResult> Mine()
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicianProfiles.GetByUserIdAsync(userId);
        if (technician == null) return NotFound();
        return Ok((await _service.GetByTechnicianIdAsync(technician.Id)).Select(Map));
    }

    [HttpGet("technician/{technicianId:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetByTechnician(int technicianId) => Ok((await _service.GetByTechnicianIdAsync(technicianId)).Select(Map));

    [HttpPost]
    [Authorize(Roles = "Technician")]
    public async Task<IActionResult> Create(CreateServiceRequestOfferRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicianProfiles.GetByUserIdAsync(userId);
        if (technician == null) return NotFound(new { message = "Technician profile not found." });
        var result = await _service.CreateAsync(request.ServiceRequestId, technician.Id, request.ProposedPrice, request.TechnicianNote);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(Map(result.Offer!));
    }

    [HttpPost("{id:int}/accept")]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> Accept(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var result = await _service.AcceptAsync(id, userId);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(new { message = "Offer accepted." });
    }

    [HttpPost("{id:int}/reject")]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> Reject(int id)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var result = await _service.RejectAsync(id, userId);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(new { message = "Offer rejected." });
    }

    private async Task<bool> CanAccessRequestAsync(HomeFix.DAL.Entities.ServiceRequest request)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        if (User.IsInRole("Customer"))
        {
            var customer = await _customerProfiles.GetByUserIdAsync(userId);
            return customer != null && customer.Id == request.CustomerId;
        }
        if (User.IsInRole("Technician"))
        {
            var technician = await _technicianProfiles.GetByUserIdAsync(userId);
            return technician != null && request.Booking?.TechnicianId == technician.Id;
        }
        return false;
    }

    private bool TryGetUserId(out int userId) => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static ServiceRequestOfferDto Map(HomeFix.DAL.Entities.ServiceRequestOffer offer) => new()
    { Id = offer.Id, ServiceRequestId = offer.ServiceRequestId, TechnicianId = offer.TechnicianId, TechnicianName = offer.Technician?.User?.FullName, ProposedPrice = offer.ProposedPrice, TechnicianNote = offer.TechnicianNote, Status = offer.Status, CreatedAt = offer.CreatedAt, ExpiresAt = offer.ExpiresAt, RespondedAt = offer.RespondedAt };
}
