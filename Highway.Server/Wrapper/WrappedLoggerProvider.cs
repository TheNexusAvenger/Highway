namespace Highway.Server.Wrapper;

public class WrappedLoggerProvider : ILoggerProvider
{
    /// <summary>
    /// Minimum log level to show.
    /// </summary>
    private readonly LogLevel _logLevel;
    
    /// <summary>
    /// Creates a wrapper logger provider.
    /// </summary>
    /// <param name="logLevel">Minimum log level to show.</param>
    public WrappedLoggerProvider(LogLevel logLevel)
    {
        this._logLevel = logLevel;
    }
    
    /// <summary>
    /// Creates a logger.
    /// </summary>
    /// <param name="categoryName">Category of the logger.</param>
    /// <returns>Logger for the application.</returns>
    public ILogger CreateLogger(string categoryName)
    {
        return new WrappedLogger(this._logLevel, Logger.NexusLogger.CreateLogger(categoryName));
    }
    
    /// <summary>
    /// Disposes of the log provider.
    /// </summary>
    public void Dispose()
    {
        GC.SuppressFinalize(this);
    }
}