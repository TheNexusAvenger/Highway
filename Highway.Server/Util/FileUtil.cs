namespace Highway.Server.Util;

public static class FileUtil
{
    /// <summary>
    /// Name of the directory used by git projects.
    /// </summary>
    public const string GitDirectoryName = ".git";
    
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
}