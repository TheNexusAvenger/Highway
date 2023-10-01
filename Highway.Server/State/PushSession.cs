using System.Security;
using Highway.Server.Model.State;
using Highway.Server.Util;

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
        if (!this.ScriptHashCollection.Hashes.ContainsKey(path))
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
    /// Completes the session and builds the script instance tree for the scripts.
    /// </summary>
    /// <returns>the instance tree for the scripts.</returns>
    /// <exception cref="KeyNotFoundException">At least one script source was not sent.</exception>
    public ScriptInstance Complete()
    {
        // Remove the session.
        Sessions.Remove(this.Id);
        
        // Throw an exception if the session is incomplete.
        // Because Add throws exceptions for extra scripts, checking for missing is all that is required.
        if (this.Scripts.Count < this.ScriptHashCollection.Hashes.Count)
        {
            throw new KeyNotFoundException("At least one script source was not sent when the hash was given");
        }
        
        // Create and return the instances.
        var rootInstance = new ScriptInstance();
        foreach (var (path, source) in this.Scripts)
        {
            rootInstance.AddScript(path, source);
        }
        return rootInstance;
    }
}