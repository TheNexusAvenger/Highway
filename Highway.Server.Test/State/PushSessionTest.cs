using System.Security;
using Highway.Server.Model.State;
using Highway.Server.State;
using Highway.Server.Util;
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
                {"Path1/Path2/Path3", HashUtil.GetHash("Source2")},
                {"Path1/Path2/Path4", HashUtil.GetHash("Source3")},
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
        this._pushSession.Add("Path1/Path2/Path3", "Source2");
        this._pushSession.Add("Path1/Path2/Path4", "Source3");

        var scriptInstance = this._pushSession.Complete();
        var child1 = scriptInstance.Children.First(child => child.Name == "Path1");
        var child2 = child1.Children.First(child => child.Name == "Path2");
        Assert.That(child2.Source, Is.EqualTo("Source1"));
        Assert.That(child2.Children.First(child => child.Name == "Path3").Source, Is.EqualTo("Source2"));
        Assert.That(child2.Children.First(child => child.Name == "Path4").Source, Is.EqualTo("Source3"));
    }

    [Test]
    public void TestCompleteIncomplete()
    {
        this._pushSession.Add("Path1/Path2", "Source1");
        this._pushSession.Add("Path1/Path2/Path4", "Source3");
        
        Assert.Throws<KeyNotFoundException>(() => this._pushSession.Complete());
    }
}