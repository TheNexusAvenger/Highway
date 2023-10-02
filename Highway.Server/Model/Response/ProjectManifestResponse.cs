using Highway.Server.Model.Project;

namespace Highway.Server.Model.Response;

public class ProjectManifestResponse : BaseResponse
{
    /// <summary>
    /// Manifest of the project.
    /// </summary>
    public Manifest Manifest { get; set; } = null!;
}