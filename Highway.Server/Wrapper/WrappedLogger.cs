namespace Highway.Server.Wrapper;

public class WrappedLogger : ILogger
{
    /// <summary>
    /// Minimum log level to show.
    /// </summary>
    private readonly LogLevel _logLevel;

    /// <summary>
    /// Base logger to call.
    /// </summary>
    private readonly ILogger _logger;
    
    /// <summary>
    /// Creates a wrapper logger.
    /// </summary>
    /// <param name="logLevel">Minimum log level to show.</param>
    /// <param name="logger">Base logger to call.</param>
    public WrappedLogger(LogLevel logLevel, ILogger logger)
    {
        this._logLevel = logLevel;
        this._logger = logger;
    }

    /// <summary>Begins a logical operation scope.</summary>
    /// <param name="state">The identifier for the scope.</param>
    /// <typeparam name="TState">The type of the state to begin scope for.</typeparam>
    /// <returns>An <see cref="T:System.IDisposable" /> that ends the logical operation scope on dispose.</returns>
    public IDisposable? BeginScope<TState>(TState state) where TState : notnull
    {
        return null;
    }

    /// <summary>
    /// Checks if the given <paramref name="logLevel" /> is enabled.
    /// </summary>
    /// <param name="logLevel">Level to be checked.</param>
    /// <returns><c>true</c> if enabled.</returns>
    public bool IsEnabled(LogLevel logLevel)
    {
        return true;
    }

    /// <summary>Writes a log entry.</summary>
    /// <param name="logLevel">Entry will be written on this level.</param>
    /// <param name="eventId">Id of the event.</param>
    /// <param name="state">The entry to be written. Can be also an object.</param>
    /// <param name="exception">The exception related to this entry.</param>
    /// <param name="formatter">Function to create a <see cref="T:System.String" /> message of the <paramref name="state" /> and <paramref name="exception" />.</param>
    /// <typeparam name="TState">The type of the object to be written.</typeparam>
    public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception? exception, Func<TState, Exception?, string> formatter)
    {
        if (logLevel < this._logLevel) return;
        this._logger.Log(logLevel, eventId, state, exception, formatter);
    }
}