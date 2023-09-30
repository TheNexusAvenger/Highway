namespace Highway.Server.Model.State;

public class ScriptHashCollection
{
    /// <summary>
    /// Hash method used for the collection.
    /// It will probably stay SHA256, but it is here in case it changes.
    /// </summary>
    public string HashMethod { get; set; } = "SHA256";

    /// <summary>
    /// Current hashes of the script contents in Roblox Studio.
    /// </summary>
    public Dictionary<string, string> Hashes { get; set; } = new Dictionary<string, string>();
}