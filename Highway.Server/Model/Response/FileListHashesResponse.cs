using Highway.Server.Model.State;

namespace Highway.Server.Model.Response;

public class FileListHashesResponse : BaseResponse
{
    /// <summary>
    /// If true, the client should re-sync the files as if it were the first connection.
    /// </summary>
    public bool Resync { get; set; } = false;
    
    /// <summary>
    /// Hashes of the current file system.
    /// </summary>
    public ScriptHashCollection? Hashes { get; set; } = null!;
}