namespace Highway.Server.Model.Response;

public class FileReadResponse : BaseResponse
{
    /// <summary>
    /// Contents of the file.
    /// </summary>
    public string Contents { get; set; } = null!;
}