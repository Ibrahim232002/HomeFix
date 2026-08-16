using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class ServiceRequestFile
{
    public int Id { get; set; }

    public int ServiceRequestId { get; set; }

    public string FileUrl { get; set; } = null!;

    public string FileType { get; set; } = null!;

    public DateTime UploadedAt { get; set; }

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;
}
