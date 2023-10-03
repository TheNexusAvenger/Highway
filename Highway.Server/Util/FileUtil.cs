using Newtonsoft.Json;

namespace Highway.Server.Util;

public static class FileUtil
{
    /// <summary>
    /// Name of the directory used by git projects.
    /// </summary>
    public const string GitDirectoryName = ".git";

    /// <summary>
    /// Name of the file for storing the project information.
    /// </summary>
    public const string ProjectFileName = "highway.json";

    /// <summary>
    /// Name of the file for storing the project hashes.
    /// </summary>
    public const string HashesFileName = "highway-hashes.json";

    /// <summary>
    /// Cached contents of JSON files.
    /// </summary>
    private static readonly Dictionary<string, object?> CachedFileObjects = new Dictionary<string, object?>();
    
    /// <summary>
    /// Returns the parent directory of a file/directory from the working directory or above.
    /// Returns null if the file/directory does not exist.
    /// </summary>
    /// <param name="fileName">File or directory name to find.</param>
    /// <returns>The parent directory of the file or directory, or null.</returns>
    public static string? GetParentDirectoryOf(string fileName)
    {
        var currentPath = Directory.GetCurrentDirectory();
        while (currentPath != null && !Path.Exists(Path.Combine(currentPath, fileName)))
        {
            currentPath = Directory.GetParent(currentPath)?.FullName;
        }
        return currentPath;
    }

    /// <summary>
    /// Returns the project directory (contains the project file).
    /// </summary>
    /// <returns>The current project directory.</returns>
    public static string? GetProjectDirectory()
    {
        return GetParentDirectoryOf(ProjectFileName);
    }

    /// <summary>
    /// Find a file or directory in the current working directory or parent.
    /// Returns null if the file/directory does not exist.
    /// </summary>
    /// <param name="fileName">File or directory name to find.</param>
    /// <returns>The path of the file or directory, or null.</returns>
    public static string? FindFileInParent(string fileName)
    {
        var parentDirectory = GetParentDirectoryOf(fileName);
        return parentDirectory == null ? null : Path.Combine(parentDirectory, fileName);
    }

    /// <summary>
    /// Reads a JSON object from a file.
    /// </summary>
    /// <param name="path">Path of the JSON file to read.</param>
    /// <typeparam name="T">Type of the JSON object to load.</typeparam>
    /// <returns>The parsed object of the path.</returns>
    public static T? Load<T>(string? path)
    {
        if (path == null) return default;
        if (!File.Exists(path)) return default;
        return JsonConvert.DeserializeObject<T>(File.ReadAllText(path));
    }

    /// <summary>
    /// Reads and caches JSON object from a file.
    /// </summary>
    /// <param name="path">Path of the JSON file to read.</param>
    /// <typeparam name="T">Type of the JSON object to load.</typeparam>
    /// <returns>The parsed object of the path.</returns>
    public static T? Get<T>(string? path)
    {
        if (path == null) return default;
        if (!CachedFileObjects.ContainsKey(path))
        {
            CachedFileObjects[path] = Load<T>(path);
        }
        return (T?) CachedFileObjects[path];
    }
}