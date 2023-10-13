using Highway.Server.Model.State;
using Highway.Server.Util;
using NUnit.Framework;

namespace Highway.Server.Test.Model.Project;

public class ScriptHashCollectionTest
{
    [Test]
    public void TestSortHashKeys()
    {
        var hashCollection = new ScriptHashCollection();
        hashCollection.Hashes!["Path5"] = "hash5";
        hashCollection.Hashes!["Path4"] = "hash4";
        hashCollection.Hashes!["path3"] = "hash3";
        hashCollection.Hashes!["Path2"] = "hash2";
        hashCollection.Hashes!["Path1"] = "hash1";
        
        Assert.That(hashCollection.Hashes.Keys, Is.Not.EqualTo(new List<string>() {"Path1", "Path2", "path3", "Path4", "Path5"}));
        hashCollection.SortHashes();
        Assert.That(hashCollection.Hashes.Keys, Is.EqualTo(new List<string>() {"Path1", "Path2", "path3", "Path4", "Path5"}));
    }
    
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