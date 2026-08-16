using HomeFix.API.DTOs.TechnicianDocument;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TechnicianDocumentsController : ControllerBase
{
    private readonly ITechnicianDocumentService _service;

    public TechnicianDocumentsController(
        ITechnicianDocumentService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<TechnicianDocumentDto>> GetById(int id)
    {
        var document = await _service.GetByIdAsync(id);

        if (document == null)
            return NotFound();

        return Ok(MapToDto(document));
    }

    [HttpGet("technician/{technicianId:int}")]
    public async Task<ActionResult<List<TechnicianDocumentDto>>>
        GetByTechnicianId(int technicianId)
    {
        var documents =
            await _service.GetByTechnicianIdAsync(technicianId);

        return Ok(documents.Select(MapToDto).ToList());
    }

    [HttpGet("pending")]
    public async Task<ActionResult<List<TechnicianDocumentDto>>>
        GetPending()
    {
        var documents = await _service.GetPendingAsync();

        return Ok(documents.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<TechnicianDocumentDto>> Create(
        CreateTechnicianDocumentRequest request)
    {
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