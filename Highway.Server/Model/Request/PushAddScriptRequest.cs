namespace Highway.Server.Model.Request;

public class PushAddScriptRequest
{
    /// <summary>
    /// Session the script is part of.
    /// </summary>
    public string? Session { get; set; } = null!;
    
    /// <summary>
    /// Path of the script.
    /// </summary>
    public string? ScriptPath { get; set; } = null!;

    /// <summary>
    /// Contents of the script.
    /// </summary>
    public string? Contents { get; set; } = null!;
}