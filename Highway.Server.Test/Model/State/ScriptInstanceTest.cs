using Highway.Server.Model.State;
using NUnit.Framework;

namespace Highway.Server.Test.Model.State;

public class ScriptInstanceTest
{
    private ScriptInstance _scriptInstance = null!;
    
    [SetUp]
    public void SetUp()
    {
        this._scriptInstance = new ScriptInstance();
    }
    
    [Test]
    public void TestAddScriptDirectChild()
    {
        this._scriptInstance.AddScript("Name", "Source");

        var childScript = this._scriptInstance.Children.First();
        Assert.That(childScript.Name, Is.EqualTo("Name"));
        Assert.That(childScript.Source, Is.EqualTo("Source"));
        Assert.That(this._scriptInstance.Children.Count, Is.EqualTo(1));
        Assert.That(childScript.Children.Count, Is.EqualTo(0));
    }
    
    [Test]
    public void TestAddScriptSplitPath()
    {
        this._scriptInstance.AddScript("Name1/Name2/Name3", "Source");

        var childScript1 = this._scriptInstance.Children.First();
        var childScript2 = childScript1.Children.First();
        var childScript3 = childScript2.Children.First();
        Assert.That(childScript1.Name, Is.EqualTo("Name1"));
        Assert.That(childScript1.Source, Is.Null);
        Assert.That(childScript2.Name, Is.EqualTo("Name2"));
        Assert.That(childScript2.Source, Is.Null);
        Assert.That(childScript3.Name, Is.EqualTo("Name3"));
        Assert.That(childScript3.Source, Is.EqualTo("Source"));
        Assert.That(this._scriptInstance.Children.Count, Is.EqualTo(1));
        Assert.That(childScript1.Children.Count, Is.EqualTo(1));
        Assert.That(childScript2.Children.Count, Is.EqualTo(1));
        Assert.That(childScript3.Children.Count, Is.EqualTo(0));
    }
    
    [Test]
    public void TestAddScriptMultipleChildren()
    {
        this._scriptInstance.AddScript("Name1/Name2/Name3", "Source1");
        this._scriptInstance.AddScript("Name1/Name2/Name4", "Source2");
        this._scriptInstance.AddScript("Name1/Name2", "Source3");

        var childScript1 = this._scriptInstance.Children.First();
        var childScript2 = childScript1.Children.First();
        var childScript3 = childScript2.Children.First(child => child.Name == "Name3");
        var childScript4 = childScript2.Children.First(child => child.Name == "Name4");
        Assert.That(childScript1.Name, Is.EqualTo("Name1"));
        Assert.That(childScript1.Source, Is.Null);
        Assert.That(childScript2.Name, Is.EqualTo("Name2"));
        Assert.That(childScript2.Source, Is.EqualTo("Source3"));
        Assert.That(childScript3.Name, Is.EqualTo("Name3"));
        Assert.That(childScript3.Source, Is.EqualTo("Source1"));
        Assert.That(childScript4.Name, Is.EqualTo("Name4"));
        Assert.That(childScript4.Source, Is.EqualTo("Source2"));
        Assert.That(this._scriptInstance.Children.Count, Is.EqualTo(1));
        Assert.That(childScript1.Children.Count, Is.EqualTo(1));
        Assert.That(childScript2.Children.Count, Is.EqualTo(2));
        Assert.That(childScript3.Children.Count, Is.EqualTo(0));
        Assert.That(childScript4.Children.Count, Is.EqualTo(0));
    }
}