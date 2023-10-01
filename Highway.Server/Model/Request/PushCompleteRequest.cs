namespace Highway.Server.Model.Request;

public class PushCompleteRequest
{
    /// <summary>
    /// Script push session to complete.
    /// </summary>
    public string? Session { get; set; } = null!;
}