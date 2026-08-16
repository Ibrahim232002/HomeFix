using HomeFix.API.DTOs.TechnicianDocument;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TechnicianDocumentsController : ControllerBase
{
    private readonly ITechnicianDocumentService _service;
    private readonly ITechnicianProfileService _technicianProfiles;

    public TechnicianDocumentsController(
        ITechnicianDocumentService service,
        ITechnicianProfileService technicianProfiles)
    {
        _service = service;
        _technicianProfiles = technicianProfiles;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<TechnicianDocumentDto>> GetById(int id)
    {
        var document = await _service.GetByIdAsync(id);

        if (document == null)
            return NotFound();
        if (!await CanAccessTechnicianAsync(document.TechnicianId)) return Forbid();

        return Ok(MapToDto(document));
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<TechnicianDocumentDto>>>
        GetByTechnicianId(int technicianId)
    {
        if (!await CanAccessTechnicianAsync(technicianId)) return Forbid();
        var documents =
            await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(documents.Select(MapToDto).ToList());
    }

    [Authorize(Roles = "Admin")]
    [HttpGet("pending")]
    public async Task<ActionResult<List<TechnicianDocumentDto>>>
        GetPending()
    {
        var documents = await _service.GetPendingAsync();

        return Ok(documents.Select(MapToDto).ToList());
    }

    [Authorize(Roles = "Technician")]
    [HttpPost]
    public async Task<ActionResult<TechnicianDocumentDto>> Create(
        CreateTechnicianDocumentRequest request)
    {
        if (!TryGetUserId(out var userId)) return Unauthorized();
        var technician = await _technicianProfiles.GetByUserIdAsync(userId);
        if (technician == null || technician.Id != request.TechnicianId) return Forbid();
        var document = new TechnicianDocument
        {
            TechnicianId = request.TechnicianId,
            DocumentType = request.DocumentType,
            DocumentUrl = request.DocumentUrl,
            UploadedAt = DateTime.UtcNow,
            Status = "Pending"
        };

        await _service.AddAsync(document);

        return CreatedAtAction(
            nameof(GetById),
            new { id = document.Id },
            MapToDto(document));
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    public async Task<ActionResult<TechnicianDocumentDto>> Update(
        int id,
        UpdateTechnicianDocumentRequest request)
    {
        var document = await _service.GetByIdAsync(id);

        if (document == null)
            return NotFound();

        document.Status = request.Status;
        document.RejectionReason = request.RejectionReason;
        document.ReviewedAt = request.ReviewedAt;

        await _service.UpdateAsync(document);

        return Ok(MapToDto(document));
    }

    private async Task<bool> CanAccessTechnicianAsync(int technicianId)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        var technician = await _technicianProfiles.GetByUserIdAsync(userId);
        return technician != null && technician.Id == technicianId;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static TechnicianDocumentDto MapToDto(
        TechnicianDocument document)
    {
        return new TechnicianDocumentDto
        {
            Id = document.Id,
            TechnicianId = document.TechnicianId,
            DocumentType = document.DocumentType,
            DocumentUrl = document.DocumentUrl,
            UploadedAt = document.UploadedAt,
            Status = document.Status,
            RejectionReason = document.RejectionReason,
            ReviewedAt = document.ReviewedAt
        };
    }
}