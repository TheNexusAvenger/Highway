using Microsoft.AspNetCore.Mvc;

namespace Highway.Server.Model.Response;

public class BaseResponse
{
    /// <summary>
    /// Computer-readable status message of the response.
    /// </summary>
    public string Status { get; set; } = "Success";
    
    /// <summary>
    /// Optional human-readable message for the response.
    /// </summary>
    public string? Message { get; set; }

    /// <summary>
    /// Converts the response to an ObjectResponse.
    /// </summary>
    /// <param name="statusCode">Status code to return.</param>
    /// <returns>Object response to return in the controller.</returns>
    public ObjectResult ToObjectResult(ushort statusCode)
    {
        return new ObjectResult(this)
        {
            StatusCode = statusCode,
        };
    }
}