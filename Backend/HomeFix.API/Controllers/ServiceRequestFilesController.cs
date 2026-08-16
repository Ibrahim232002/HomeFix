using HomeFix.API.DTOs.ServiceRequestFile;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ServiceRequestFilesController : ControllerBase
{
    private readonly IServiceRequestFileService _service;

    public ServiceRequestFilesController(
        IServiceRequestFileService service)
    {
        _service = service;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ServiceRequestFileDto>> GetById(int id)
    {
        var file = await _service.GetByIdAsync(id);

        if (file == null)
            return NotFound();

        return Ok(MapToDto(file));
    }

    [HttpGet("request/{serviceRequestId:int}")]
    public async Task<ActionResult<List<ServiceRequestFileDto>>> GetByRequestId(
        int serviceRequestId)
    {
        var files = await _service.GetByRequestIdAsync(serviceRequestId);

        return Ok(files.Select(MapToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<ServiceRequestFileDto>> Create(
        CreateServiceRequestFileRequest request)
    {
        var file = new ServiceRequestFile
        {
            ServiceRequestId = request.ServiceRequestId,
            FileUrl = request.FileUrl,
            FileType = request.FileType,
            UploadedAt = DateTime.UtcNow
        };

        await _service.AddAsync(file);

        return CreatedAtAction(
            nameof(GetById),
            new { id = file.Id },
            MapToDto(file));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var file = await _service.GetByIdAsync(id);

        if (file == null)
            return NotFound();

        await _service.DeleteAsync(file);

        return NoContent();
    }

    private static ServiceRequestFileDto MapToDto(
        ServiceRequestFile file)
    {
        return new ServiceRequestFileDto
        {
            Id = file.Id,
            ServiceRequestId = file.ServiceRequestId,
            FileUrl = file.FileUrl,
            FileType = file.FileType,
            UploadedAt = file.UploadedAt
        };
    }
}