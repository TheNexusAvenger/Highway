namespace Highway.Server.Model.Project;

public class Manifest
{
    /// <summary>
    /// Optional display name of the project.
    /// </summary>
    public string? Name { get; set; }
    
    /// <summary>
    /// Optional place id to require for pulling/pushing changes.
    /// </summary>
    public long? PushPlaceId { get; set; }
    
    /// <summary>
    /// Optional place id to require for live syncing changes.
    /// </summary>
    public long? SyncPlaceId { get; set; }

    /// <summary>
    /// Dictionary of the Studio paths to the file system paths to sync.
    /// </summary>
    public Dictionary<string, string> Paths { get; set; } = null!;
}