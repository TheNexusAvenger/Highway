using System.Security;
using Highway.Server.Model.State;
using Highway.Server.State;
using Highway.Server.Util;
using Newtonsoft.Json;
using NUnit.Framework;

namespace Highway.Server.Test.State;

public class PushSessionTest
{
    private PushSession _pushSession = null!;
    
    [SetUp]
    public void SetUp()
    {
        this._pushSession = new PushSession(new ScriptHashCollection()
        {
            Hashes = new Dictionary<string, string>()
            {
                {"Path1/Path2", HashUtil.GetHash("Source1")},
                {"Path1/Path3/Path4", HashUtil.GetHash("Source2")},
                {"Path1/Path3/Path5", HashUtil.GetHash("Source3")},
                {"Path1/Path6/Path7", HashUtil.GetHash("Source4")},
            }
        });
    }

    [Test]
    public void TestAdd()
    {
        this._pushSession.Add("Path1/Path2", "Source1");
        Assert.That(this._pushSession.Scripts["Path1/Path2"], Is.EqualTo("Source1"));
    }

    [Test]
    public void TestAddNotFoundPath()
    {
        Assert.Throws<KeyNotFoundException>(() => this._pushSession.Add("Path1/Path3", "Source1"));
    }

    [Test]
    public void TestAddHashMismatch()
    {
        Assert.Throws<SecurityException>(() => this._pushSession.Add("Path1/Path2", "Source2"));
    }

    [Test]
    public void TestComplete()
    {
        this._pushSession.Add("Path1/Path2", "Source1");
        this._pushSession.Add("Path1/Path3/Path4", "Source2");
        this._pushSession.Add("Path1/Path3/Path5", "Source3");
        this._pushSession.Add("Path1/Path6/Path7", "Source4");

        this._pushSession.Complete();
    }

    [Test]
    public void TestCompleteIncomplete()
    {
        this._pushSession.Add("Path1/Path2", "Source1");
        this._pushSession.Add("Path1/Path3/Path5", "Source3");
        this._pushSession.Add("Path1/Path6/Path7", "Source4");
        
        Assert.Throws<KeyNotFoundException>(() => this._pushSession.Complete());
    }

    [Test]
    public void TestWriteFilesNewProject()
    {
        this._pushSession.Add("Path1/Path2", "Source1");
        this._pushSession.Add("Path1/Path3/Path4", "Source2");
        this._pushSession.Add("Path1/Path3/Path5", "Source3");
        this._pushSession.Add("Path1/Path6/Path7", "Source4");
        this._pushSession.Complete();
        
        var temporaryDirectory = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
        Directory.CreateDirectory(temporaryDirectory);
        this._pushSession.WriteFilesAsync(temporaryDirectory, new Dictionary<string, string>()
        {
            {"Path1", "src/path1"},
            {"Path1.Path6", "src/path6/"}
        }).Wait();
        
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "src/path1/Path2")), Is.EqualTo("Source1"));
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "src/path1/Path3/Path4")), Is.EqualTo("Source2"));
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "src/path1/Path3/Path5")), Is.EqualTo("Source3"));
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "src/path6/Path7")), Is.EqualTo("Source4"));
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "highway-hashes.json")), Is.EqualTo(JsonConvert.SerializeObject(this._pushSession.ScriptHashCollection, Formatting.Indented)));
    }

    [Test]
    public void TestWriteFilesExistingProject()
    {
        this._pushSession.Add("Path1/Path2", "Source1");
        this._pushSession.Add("Path1/Path3/Path4", "Source2");
        this._pushSession.Add("Path1/Path3/Path5", "Source3");
        this._pushSession.Add("Path1/Path6/Path7", "Source4");
        this._pushSession.Complete();
        
        var temporaryDirectory = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
        Directory.CreateDirectory(Path.Combine(temporaryDirectory, "src/Path1"));
        File.WriteAllText(Path.Combine(temporaryDirectory, "src/Path1/Path2"), "Source1");
        File.WriteAllText(Path.Combine(temporaryDirectory, "src/Path1/Path8"), "Source5");
        File.WriteAllText(Path.Combine(temporaryDirectory, FileUtil.HashesFileName), JsonConvert.SerializeObject(new ScriptHashCollection()
        {
            Hashes = new Dictionary<string, string>() {
                {"Path1/Path2", HashUtil.GetHash("Source1")},
                {"Path1/Path8", HashUtil.GetHash("Source5")},
            },
        }));

        this._pushSession.WriteFilesAsync(temporaryDirectory, new Dictionary<string, string>()
        {
            {"Path1", "src/path1"},
            {"Path1.Path6", "src/path6/"}
        }).Wait();
        
        Assert.That(File.Exists(Path.Combine(temporaryDirectory, "src/path1/Path8")), Is.EqualTo(false));
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "src/path1/Path2")), Is.EqualTo("Source1"));
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "src/path1/Path3/Path4")), Is.EqualTo("Source2"));
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "src/path1/Path3/Path5")), Is.EqualTo("Source3"));
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "src/path6/Path7")), Is.EqualTo("Source4"));
        Assert.That(File.ReadAllText(Path.Combine(temporaryDirectory, "highway-hashes.json")), Is.EqualTo(JsonConvert.SerializeObject(this._pushSession.ScriptHashCollection, Formatting.Indented)));
    }
}