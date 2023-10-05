namespace Highway.Server.Model.Request;

public class PushCompleteRequest
{
    /// <summary>
    /// Script push session to complete.
    /// </summary>
    public string? Session { get; set; } = null!;
    
    /// <summary>
    /// Branch to check out from the remote when pushing from Roblox Studio.
    /// </summary>
    public string? CheckoutBranch { get; set; }

    /// <summary>
    /// Branch to push to the remote when pushing from Roblox Studio.
    /// </summary>
    public string? PushBranch { get; set; }
        
    /// <summary>
    /// Override commit message when commiting changes from Roblox Studio.
    /// </summary>
    public string? CommitMessage { get; set; }
}