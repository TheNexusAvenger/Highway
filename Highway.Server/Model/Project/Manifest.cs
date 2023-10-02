namespace Highway.Server.Model.Project;

public class Manifest
{
    public class GitManifestEntry
    {
        /// <summary>
        /// Branch to check out from the remote when pushing from Roblox Studio.
        /// </summary>
        public string CheckoutBranch { get; set; } = null!;

        /// <summary>
        /// Branch to push to the remote when pushing from Roblox Studio.
        /// </summary>
        public string PushBranch { get; set; } = null!;
    }
    
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
    /// Configuration for the git remote.
    /// </summary>
    public GitManifestEntry Git { get; set; } = null!;

    /// <summary>
    /// Dictionary of the Studio paths to the file system paths to sync.
    /// </summary>
    public Dictionary<string, string> Paths { get; set; } = null!;
}