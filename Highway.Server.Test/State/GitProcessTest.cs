using Highway.Server.Model.State;
using NUnit.Framework;

namespace Highway.Server.Test.State;

public class GitProcessTest
{
    [Test]
    public void TestRunForkAsync()
    {
        var temporaryGitDirectory = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
        Directory.CreateDirectory(temporaryGitDirectory);
        var gitProcess = new GitProcess(temporaryGitDirectory);
        Assert.That(gitProcess.RunCommandAsync("init").Result, Is.EqualTo(0));
        Assert.That(gitProcess.RunCommandAsync("config user.name TestUser").Result, Is.EqualTo(0));

        var forkedGitProcess = gitProcess.ForkAsync().Result;
        var newConfigContents = File.ReadAllText(Path.Combine(forkedGitProcess.GitPath, ".git", "config"));
        Assert.That(gitProcess.GitPath, Is.Not.EqualTo(forkedGitProcess.GitPath));
        Assert.That(newConfigContents, Does.Contain("name = TestUser"));
    }
}