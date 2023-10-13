using System.Security;
using Highway.Server.Model.Project;
using Highway.Server.Model.State;
using Highway.Server.Util;
using Newtonsoft.Json;

namespace Highway.Server.State;

public class PushSession
{
    /// <summary>
    /// Active sessions for pushing files.
    /// </summary>
    private static readonly Dictionary<string, PushSession> Sessions = new Dictionary<string, PushSession>();

    /// <summary>
    /// Id of the session.
    /// </summary>
    public readonly string Id;

    /// <summary>
    /// 
    /// </summary>
    public readonly ScriptHashCollection ScriptHashCollection;

    /// <summary>
    /// Dictionary of the script paths to the contents.
    /// </summary>
    public Dictionary<string, string> Scripts = new Dictionary<string, string>();

    /// <summary>
    /// Creates a push session.
    /// </summary>
    public PushSession(ScriptHashCollection scriptHashCollection)
    {
        this.Id = Guid.NewGuid().ToString();
        this.ScriptHashCollection = scriptHashCollection;
    }

    /// <summary>
    /// Creates and stores a new push session.
    /// </summary>
    /// <param name="scriptHashCollection">Script hash collection for the push.</param>
    /// <returns>New push session.</returns>
    public static PushSession Create(ScriptHashCollection scriptHashCollection)
    {
        var newSession = new PushSession(scriptHashCollection);
        Sessions[newSession.Id] = newSession;
        return newSession;
    }

    /// <summary>
    /// Returns the push session for the given id.
    /// </summary>
    /// <param name="id">Id of the session.</param>
    /// <returns>Push session for an id.</returns>
    public static PushSession? Get(string id)
    {
        return Sessions[id];
    }

    /// <summary>
    /// Adds a script to the session.
    /// </summary>
    /// <param name="path">Path of the script.</param>
    /// <param name="source">Source of the script.</param>
    /// <exception cref="KeyNotFoundException">The path was not stored in the hash collection.</exception>
    /// <exception cref="SecurityException">The hash of the script source does not match what was sent in the hash collection.</exception>
    public void Add(string path, string source)
    {
        // Throw an exception if the script does not have a hash.
        if (!this.ScriptHashCollection.Hashes!.ContainsKey(path))
        {
            throw new KeyNotFoundException($"Script path has no stored hash: {path}");
        }
        
        // Throw an exception if the hash does not match.
        var hash = HashUtil.GetHash(source);
        var existingHash = this.ScriptHashCollection.Hashes[path];
        if (hash != existingHash)
        {
            throw new SecurityException($"Script hashes do not match ({existingHash} != {hash}).");
        }
        
        // Store the script.
        this.Scripts[path] = source;
    }

    /// <summary>
    /// Completes the session and removes it from the active sessions.
    /// </summary>
    /// <exception cref="KeyNotFoundException">At least one script source was not sent.</exception>
    public void Complete()
    {
        // Remove the session.
        Sessions.Remove(this.Id);
        
        // Throw an exception if the session is incomplete.
        // Because Add throws exceptions for extra scripts, checking for missing is all that is required.
        if (this.Scripts.Count < this.ScriptHashCollection.Hashes!.Count)
        {
            throw new KeyNotFoundException("At least one script source was not sent when the hash was given");
        }
    }

    /// <summary>
    /// Writes the files of the session.
    /// </summary>
    /// <param name="parentDirectory">Parent directory to write to.</param>
    /// <param name="manifest">Manifest of the project.</param>
    public async Task WriteFilesAsync(string parentDirectory, Manifest manifest)
    {
        // Remove old files not stored in the new hash collection.
        // Empty folders aren't cleared since they will not be saved by git.
        var hashesFilePath = Path.Combine(parentDirectory, FileUtil.HashesFileName);
        if (File.Exists(hashesFilePath))
        {
            var previousHashes = JsonConvert.DeserializeObject<ScriptHashCollection>(await File.ReadAllTextAsync(hashesFilePath))!;
            foreach (var (scriptPath, _) in previousHashes.Hashes!)
            {
                if (this.ScriptHashCollection.Hashes!.ContainsKey(scriptPath)) continue;
                var scriptFilePath = manifest.GetPathForScriptPath(parentDirectory, scriptPath);
                if (scriptFilePath == null || !File.Exists(scriptFilePath)) continue;
                File.Delete(scriptFilePath);
            }
        }
        
        // Write the new files.
        foreach (var (scriptPath, scriptContents) in this.Scripts)
        {
            var scriptFilePath = manifest.GetPathForScriptPath(parentDirectory, scriptPath);
            if (scriptFilePath == null) continue;
            Directory.CreateDirectory(Directory.GetParent(scriptFilePath)!.FullName);
            await File.WriteAllTextAsync(scriptFilePath, scriptContents);
        }
        
        // Write the hash file.
        this.ScriptHashCollection.SortHashes();
        await File.WriteAllTextAsync(hashesFilePath, JsonConvert.SerializeObject(this.ScriptHashCollection, Formatting.Indented));
    }
}