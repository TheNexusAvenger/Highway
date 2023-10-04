using Highway.Server.Util;

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
    public Dictionary<string, string>? Hashes { get; set; } = new Dictionary<string, string>();

    /// <summary>
    /// Adds file or directory tot he hash collection.
    /// </summary>
    /// <param name="baseScriptPath">Base script path to add.</param>
    /// <param name="baseDirectoryPath">Directory of the file or directory to add.</param>
    /// <param name="firstStep">Makes it so the directory is not added to the path. Only meant for the first call.</param>
    public void AddFileHashes(string baseScriptPath, string baseDirectoryPath, bool firstStep = true)
    {
        var fileName = Path.GetFileName(baseDirectoryPath);
        var scriptPath = (firstStep ? baseScriptPath : baseScriptPath + (baseScriptPath.EndsWith("/") ? "" : "/") + fileName);
        if (Directory.Exists(baseDirectoryPath))
        {
            // Add the files and directories in the directory.
            foreach (var child in Directory.GetDirectories(baseDirectoryPath))
            {
                this.AddFileHashes(scriptPath, child, false);
            }
            foreach (var child in Directory.GetFiles(baseDirectoryPath))
            {
                this.AddFileHashes(scriptPath, child, false);
            }
        }
        else if (File.Exists(baseDirectoryPath))
        {
            // Add the file.
            this.Hashes![scriptPath] = HashUtil.GetHash(File.ReadAllText(baseDirectoryPath));
        }
    }
}