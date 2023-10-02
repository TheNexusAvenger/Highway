using Highway.Server.Model.State;

namespace Highway.Server.Model.Response;

public class FileListHashesResponse : BaseResponse
{
    /// <summary>
    /// Hashes of the current file system.
    /// </summary>
    public ScriptHashCollection Hashes { get; set; } = null!;
}