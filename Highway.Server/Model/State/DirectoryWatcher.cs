using Highway.Server.Util;

namespace Highway.Server.Model.State;

public class DirectoryWatcher
{
    /// <summary>
    /// Static instances of the DirectoryWatcher.
    /// </summary>
    private static readonly Dictionary<string, DirectoryWatcher> DirectoryWatchers = new Dictionary<string, DirectoryWatcher>();
    
    /// <summary>
    /// Files that have changed since the last reset.
    /// </summary>
    public readonly HashSet<string> ChangedFiles = new HashSet<string>();
    
    /// <summary>
    /// File watcher for the directory.
    /// </summary>
    private readonly FileSystemWatcher _fileSystemWatcher;
    
    /// <summary>
    /// Creates a directory watcher.
    /// </summary>
    /// <param name="directory">Directory to watch.</param>
    private DirectoryWatcher(string directory)
    {
        this._fileSystemWatcher = new FileSystemWatcher(directory);
        this._fileSystemWatcher.NotifyFilter = NotifyFilters.DirectoryName
                                               | NotifyFilters.FileName
                                               | NotifyFilters.LastWrite
                                               | NotifyFilters.Size;
        this._fileSystemWatcher.Changed += HandleEventForFiles;
        this._fileSystemWatcher.Created += HandleEvent;
        this._fileSystemWatcher.Deleted += HandleEvent;
        this._fileSystemWatcher.Renamed += HandleEvent;
        this._fileSystemWatcher.IncludeSubdirectories = true;
        this._fileSystemWatcher.EnableRaisingEvents = true;
    }

    /// <summary>
    /// Returns a DirectoryWatcher for a given directory.
    /// </summary>
    /// <param name="directory">Directory to watch.</param>
    /// <returns>The directory watcher for the directory.</returns>
    public static DirectoryWatcher Get(string directory)
    {
        if (!DirectoryWatchers.ContainsKey(directory))
        {
            DirectoryWatchers[directory] = new DirectoryWatcher(directory);
        }
        return DirectoryWatchers[directory];
    }

    /// <summary>
    /// Returns a DirectoryWatcher for the project directory.
    /// </summary>
    /// <returns>The directory watcher for the project directory.</returns>
    public static DirectoryWatcher Get()
    {
        return Get(FileUtil.GetProjectDirectory()!);
    }

    /// <summary>
    /// Resets the changed files.
    /// </summary>
    public void Reset()
    {
        this.ChangedFiles.Clear();
    }

    /// <summary>
    /// Handles an event from a FileSystemWatcher. 
    /// </summary>
    /// <param name="sender">Sender of the event.</param>
    /// <param name="e">Data of the event.</param>
    private void HandleEvent(object sender, FileSystemEventArgs e)
    {
        this.ChangedFiles.Add(e.FullPath);
    }

    /// <summary>
    /// Handles an event from a FileSystemWatcher that filters for files. 
    /// </summary>
    /// <param name="sender">Sender of the event.</param>
    /// <param name="e">Data of the event.</param>
    private void HandleEventForFiles(object sender, FileSystemEventArgs e)
    {
        if (!File.Exists(e.FullPath)) return;
        this.ChangedFiles.Add(e.FullPath);
    }

    /// <summary>
    /// Handles a rename event from a FileSystemWatcher. 
    /// </summary>
    /// <param name="sender">Sender of the event.</param>
    /// <param name="e">Data of the event.</param>
    private void HandleEvent(object sender, RenamedEventArgs e)
    {
        this.ChangedFiles.Add(e.OldFullPath);
        this.ChangedFiles.Add(e.FullPath);
    }
}