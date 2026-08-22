using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IInspectionService
{
    Task<Inspection?> GetByIdAsync(int id);
    Task<Inspection?> GetByRequestIdAsync(int serviceRequestId);
    Task<List<Inspection>> GetByTechnicianIdAsync(int technicianId);

    Task<(bool Success, string? Error, Inspection? Inspection)> CreateAsync(int technicianId, int serviceRequestId, DateTime scheduledAt);
    Task<(bool Success, string? Error, Inspection? Inspection)> ScheduleAsync(int technicianId, int inspectionId, DateTime scheduledAt);
    Task<(bool Success, string? Error, Inspection? Inspection)> StartAsync(int technicianId, int inspectionId);
    Task<(bool Success, string? Error, Inspection? Inspection)> CompleteAsync(int technicianId, int inspectionId, string findings);
    Task<(bool Success, string? Error, Inspection? Inspection)> CancelAsync(int technicianId, int inspectionId);
    Task<(bool Success, string? Error, Inspection? Inspection)> NoShowAsync(int technicianId, int inspectionId);
}
