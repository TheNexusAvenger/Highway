namespace Highway.Server.Model.Response;

public class BaseSessionResponse : BaseResponse
{
    /// <summary>
    /// Session the response is part of.
    /// </summary>
    public string Session { get; set; } = null!;
}