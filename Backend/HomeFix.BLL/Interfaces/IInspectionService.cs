using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IInspectionService
{
    Task<Inspection?> GetByIdAsync(int id);
    Task<Inspection?> GetByRequestIdAsync(int requestId);
    Task<List<Inspection>> GetByTechnicianIdAsync(int technicianId);
    Task<(bool Success, string? Error, Inspection? Inspection)> CreateForAcceptedOfferAsync(int requestId, int technicianId);
    Task<(bool Success, string? Error)> ScheduleAsync(int inspectionId, int technicianId, DateTime scheduledAt);
    Task<(bool Success, string? Error)> StartAsync(int inspectionId, int technicianId);
    Task<(bool Success, string? Error)> CompleteAsync(int inspectionId, int technicianId, string? findings);
    Task<(bool Success, string? Error)> CancelAsync(int inspectionId, int technicianId);
    Task<(bool Success, string? Error)> NoShowAsync(int inspectionId, int technicianId);
}
