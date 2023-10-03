using Highway.Server.Model.Project;
using NUnit.Framework;

namespace Highway.Server.Test.Model.State;

public class ManifestTest
{
    [Test]
    public void TestGetPathForScriptPath()
    {
        var manifest = new Manifest()
        {
            Paths = new Dictionary<string, string>()
            {
                { "Path1", "src/path1" },
                { "Path1.Path2", "src/path2" },
            },
        };
        
        Assert.That(manifest.GetPathForScriptPath(@"C:\test", "unknown"), Is.EqualTo(null));
        Assert.That(manifest.GetPathForScriptPath(@"C:\test", "Path1/Path3/Path4"), Is.EqualTo(@"C:\test\src\path1\Path3\Path4"));
        Assert.That(manifest.GetPathForScriptPath(@"C:\test", "Path1/Path2/Path4"), Is.EqualTo(@"C:\test\src\path2\Path4"));
    }
    
    [Test]
    public void TestGetScriptPathForPath()
    {
        var manifest = new Manifest()
        {
            Paths = new Dictionary<string, string>()
            {
                { "Path1", "src/path1" },
                { "Path1.Path2", "src/path2" },
            },
        };
        
        Assert.That(manifest.GetScriptPathForPath(@"C:\test", @"C:\test\unknown"), Is.EqualTo(null));
        Assert.That(manifest.GetScriptPathForPath(@"C:\test", @"C:\test\src\path1\Path3\Path4"), Is.EqualTo("Path1/Path3/Path4"));
        Assert.That(manifest.GetScriptPathForPath(@"C:\test", @"C:\test\src\path2\Path4"), Is.EqualTo("Path1/Path2/Path4"));
    }
}