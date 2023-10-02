using System.Diagnostics;
using Highway.Server.Util;

namespace Highway.Server.Model.State;

public class GitProcess
{
    /// <summary>
    /// Path of the git project.
    /// </summary>
    public readonly string GitPath;

    /// <summary>
    /// Creates a git process object.
    /// </summary>
    /// <param name="gitPath">Path of the git project.</param>
    public GitProcess(string gitPath)
    {
        this.GitPath = gitPath;
    }

    /// <summary>
    /// Returns the current git project.
    /// </summary>
    /// <returns>The current git project.</returns>
    public static GitProcess GetCurrentProcess()
    {
        return new GitProcess(FileUtil.GetParentDirectoryOf(FileUtil.GitDirectoryName)!);
    }  
    
    /// <summary>
    /// Runs a git command.
    /// </summary>
    /// <param name="command">Command to run.</param>
    /// <returns>Return code of the command.</returns>
    public async Task<int> RunCommandAsync(string command)
    {
        var process = new Process()
        {
            StartInfo = new ProcessStartInfo()
            {
                FileName = "git",
                Arguments = command,
                WorkingDirectory = this.GitPath
            },
        };
        process.Start();
        await process.WaitForExitAsync();
        return process.ExitCode;
    }
    
    /// <summary>
    /// Forks the git repository as an empty project with the same config file to a temporary directory. 
    /// </summary>
    /// <returns>Forked git project in a temporary directory.</returns>
    public async Task<GitProcess> ForkAsync()
    {
        // Create the temporary directory and git process.
        var temporaryGitDirectory = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
        Directory.CreateDirectory(temporaryGitDirectory);
        var forkedGitProcess = new GitProcess(temporaryGitDirectory);
        
        // Initialize the git project.
        await forkedGitProcess.RunCommandAsync("init");
        File.Copy(Path.Combine(this.GitPath, ".git", "config"), Path.Combine(forkedGitProcess.GitPath, ".git", "config"), overwrite: true);
        
        // Return the forked git process.
        return forkedGitProcess;
    }
}