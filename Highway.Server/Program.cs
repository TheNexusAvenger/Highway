using Microsoft.AspNetCore.Diagnostics;

namespace Highway.Server;

public class Program
{
    /// <summary>
    /// Default port to use.
    /// </summary>
    public const ushort Port = 22894;
    
    /// <summary>
    /// Runs the program.
    /// </summary>
    /// <param name="args">Arguments from the command line.</param>
    public static void Main(string[] args)
    {
        // TODO: Support command line arguments to enable debug and not start server.
        // Build the server.
        Logger.Debug("Preparing web server.");
        var builder = WebApplication.CreateBuilder(args);
        builder.Logging.ClearProviders();
        builder.Logging.AddProvider(Logger.NexusLogger);
        builder.Services.AddControllers();
            
        // Start the server.
        var app = builder.Build();
        app.UseExceptionHandler(exceptionHandlerApp =>
        {
            exceptionHandlerApp.Run(context =>
            {
                var exceptionHandlerPathFeature = context.Features.Get<IExceptionHandlerPathFeature>();
                if (exceptionHandlerPathFeature != null)
                {
                    Logger.Error($"An exception occurred processing {context.Request.Method} {context.Request.Path}\n{exceptionHandlerPathFeature.Error}");
                }
                return Task.CompletedTask;
            });
        });
        app.MapControllers();
        Logger.Info($"Starting server on port {Port}.");
        app.Run($"http://*:{Port}");
    }
}