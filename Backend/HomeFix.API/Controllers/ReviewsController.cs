using HomeFix.API.DTOs.Review;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ReviewsController : ControllerBase
{
    private readonly IReviewService _service;

    public ReviewsController(IReviewService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ReviewDto>> GetById(int id)
    {
        var review = await _service.GetByIdAsync(id);

        if (review == null)
            return NotFound();

        return Ok(MapToDto(review));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<ReviewDto>> GetByRequestId(
        int serviceRequestId)
    {
        var review = await _service.GetByRequestIdAsync(serviceRequestId);

        if (review == null)
            return NotFound();

        return Ok(MapToDto(review));
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<ReviewDto>>> GetByTechnicianId(
        int technicianId)
    {
        var reviews = await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(reviews.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<ReviewDto>> Create(
        CreateReviewRequest request)
    {
        var review = new Review
        {
            ServiceRequestId = request.ServiceRequestId,
            CustomerId = request.CustomerId,
            TechnicianId = request.TechnicianId,
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