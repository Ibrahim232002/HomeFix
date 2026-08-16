using HomeFix.API.DTOs.Review;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ReviewsController : ControllerBase
{
    private readonly IReviewService _service;
    private readonly ICustomerProfileService _customers;
    private readonly IBookingService _bookings;

    public ReviewsController(
        IReviewService service,
        ICustomerProfileService customers,
        IBookingService bookings)
    {
        _service = service;
        _customers = customers;
        _bookings = bookings;
    }

    [AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<ActionResult<ReviewDto>> GetById(int id)
    {
        var review = await _service.GetByIdAsync(id);
        if (review == null) return NotFound();
        return Ok(MapToDto(review));
    }

    [AllowAnonymous]
    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<ReviewDto>> GetByRequestId(int serviceRequestId)
    {
        var review = await _service.GetByRequestIdAsync(serviceRequestId);
        if (review == null) return NotFound();
        return Ok(MapToDto(review));
    }

    [AllowAnonymous]
    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<ReviewDto>>> GetByTechnicianId(int technicianId)
    {
        var reviews = await _service.GetByTechnicianIdAsync(technicianId);
        return Ok(reviews.Select(MapToDto).ToList());
    }

    [Authorize(Roles = "Customer")]
    [HttpPost]
    public async Task<ActionResult<ReviewDto>> Create(CreateReviewRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        if (request.Rating is < 1 or > 5)
            return BadRequest(new { message = "Rating must be between 1 and 5." });

        var customer = await _customers.GetByUserIdAsync(userId);
        if (customer == null)
            return NotFound(new { message = "Customer profile not found." });

        var booking = await _bookings.GetByRequestIdAsync(request.ServiceRequestId);
        if (booking == null || booking.ServiceRequest.CustomerId != customer.Id)
            return Forbid();

        if (booking.Status != "Completed")
            return BadRequest(new { message = "A review can only be created after the booking is completed." });

        var existingReview = await _service.GetByRequestIdAsync(request.ServiceRequestId);
        if (existingReview != null)
            return Conflict(new { message = "A review already exists for this service request." });

        var review = new Review
        {
            ServiceRequestId = request.ServiceRequestId,
            CustomerId = customer.Id,
            TechnicianId = booking.TechnicianId,
            Rating = request.Rating,
            Comment = request.Comment,
            CreatedAt = DateTime.UtcNow
        };

        await _service.AddAsync(review);

        return CreatedAtAction(
            nameof(GetById),
            new { id = review.Id },
            MapToDto(review));
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static ReviewDto MapToDto(Review review)
    {
        return new ReviewDto
        {
            Id = review.Id,
            ServiceRequestId = review.ServiceRequestId,
            CustomerId = review.CustomerId,
            TechnicianId = review.TechnicianId,
            Rating = review.Rating,
            Comment = review.Comment,
            CreatedAt = review.CreatedAt
        };
    }
}
