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
        
        /// <summary>
        /// Override commit message when commiting changes from Roblox Studio.
        /// </summary>
        public string? CommitMessage { get; set; }
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

    /// <summary>
    /// Determines the file system path for a script path.
    /// </summary>
    /// <param name="parentDirectory">Parent directory to base the manifest off of.</param>
    /// <param name="scriptPath">Path of the script.</param>
    /// <returns>File path of the script, if any.</returns>
    public string? GetPathForScriptPath(string parentDirectory, string scriptPath)
    {
        // Determine the longest file path that matches the script path.
        string? baseScriptPath = null;
        foreach (var (newBaseScriptPath, _) in this.Paths)
        {
            if (!scriptPath.StartsWith(newBaseScriptPath.Replace('.', '/'))) continue;
            if (baseScriptPath != null && baseScriptPath.Length > newBaseScriptPath.Length) continue;
            baseScriptPath = newBaseScriptPath;
        }
        
        // Return the path.
        if (baseScriptPath == null) return null;
        return Path.Combine(parentDirectory, this.Paths[baseScriptPath], scriptPath.Replace(baseScriptPath.Replace('.', '/') + "/", ""));
    }
}