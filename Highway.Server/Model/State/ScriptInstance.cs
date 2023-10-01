namespace Highway.Server.Model.State;

public class ScriptInstance
{
    /// <summary>
    /// Name of the script.
    /// </summary>
    public string Name { get; set; } = null!;
    
    /// <summary>
    /// Source of the script.
    /// </summary>
    public string? Source { get; set; }

    /// <summary>
    /// Children of the script.
    /// </summary>
    public List<ScriptInstance> Children { get; set; } = new List<ScriptInstance>();
    
    /// <summary>
    /// Adds a script child.
    /// </summary>
    /// <param name="path">Path of the script.</param>
    /// <param name="source">Source of the script.</param>
    public void AddScript(string path, string source)
    {
        if (path.Contains('/'))
        {
            var pathPaths = path.Split('/', 2);
            this.GetChild(pathPaths[0]).AddScript(pathPaths[1], source);
        }
        else
        {
            this.GetChild(path).Source = source;
        }
    }

    /// <summary>
    /// Returns the child for a given name.
    /// Creates the child if it does not exist.
    /// </summary>
    /// <param name="name">Name of the child.</param>
    /// <returns>Name that matches the name.</returns>
    private ScriptInstance GetChild(string name)
    {
        var existingChild = this.Children.FirstOrDefault(child => child.Name == name);
        if (existingChild != null) return existingChild;
        
        var newChild = new ScriptInstance()
        {
            Name = name,
        };
        this.Children.Add(newChild);
        return newChild;
    }
}