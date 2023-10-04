using Highway.Server.Model.State;
using Highway.Server.Util;
using NUnit.Framework;

namespace Highway.Server.Test.Model.Project;

public class ScriptHashCollectionTest
{
    [Test]
    public void TestAddFileHashes()
    {
        var temporaryDirectory = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
        Directory.CreateDirectory(Path.Combine(temporaryDirectory, "src", "Path1", "Path2"));
        Directory.CreateDirectory(Path.Combine(temporaryDirectory, "src", "Path3", "Path4"));
        File.WriteAllText(Path.Combine(temporaryDirectory, "src", "Path1", "FileA"), "Source1");
        File.WriteAllText(Path.Combine(temporaryDirectory, "src", "Path1", "Path2", "FileB"), "Source2");
        File.WriteAllText(Path.Combine(temporaryDirectory, "src", "Path1", "Path2", "FileC"), "Source3");
        File.WriteAllText(Path.Combine(temporaryDirectory, "src", "Path3", "Path4", "FileD"), "Source4");

        var hashCollection = new ScriptHashCollection();
        hashCollection.AddFileHashes("PathA/PathB", Path.Combine(temporaryDirectory, "src", "Path1"));
        hashCollection.AddFileHashes("PathC", Path.Combine(temporaryDirectory, "src", "Path3"));
        Assert.That(hashCollection.Hashes, Is.EqualTo(new Dictionary<string, string>()
        {
            {"PathA/PathB/FileA", HashUtil.GetHash("Source1")},
            {"PathA/PathB/Path2/FileB", HashUtil.GetHash("Source2")},
            {"PathA/PathB/Path2/FileC", HashUtil.GetHash("Source3")},
            {"PathC/Path4/FileD", HashUtil.GetHash("Source4")},
        }));
    }
}