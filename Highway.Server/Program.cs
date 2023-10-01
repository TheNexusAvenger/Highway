using System.CommandLine;
using Highway.Server.Util;
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
    public static int Main(string[] args)
    {
        // Create the serve command.
        var debugLogToggle = new Option<bool>(
            name: "--debug",
            description: "Enables debug logging.");

        var serveCommand = new Command("serve", "Starts hosting the server for Highway.")
        {
            debugLogToggle
        };
        serveCommand.SetHandler(async (debug) => await RunServer(debug), debugLogToggle);
        
        // Create the root command.
        var rootCommand = new RootCommand("Highway - For using external editors on teams that won't use them.");
        rootCommand.AddOption(debugLogToggle);
        rootCommand.AddCommand(serveCommand);

        // Run the command and return the status code.
        return rootCommand.InvokeAsync(args).Result;
    }

    /// <summary>
    /// Verifies that Highway can start.
    /// </summary>
    /// <returns>Whether the app can start.</returns>
    private static bool Verify()
    {
        // Return if there is no git directory.
        if (FileUtil.GetParentDirectoryOf(FileUtil.GitDirectoryName) == null)
        {
            Logger.Warn("No git project found in the current directory or parent directory.");
            return false;
        }
        
        // Return true (valid to start).
        return true;
    }

    /// <summary>
    /// Runs the server.
    /// </summary>
    private static async Task RunServer(bool debug)
    {
        // Enable debug logging.
        if (debug)
        {
            Logger.SetLogLevel(LogLevel.Debug);
        }
        
        // Return if the project is not valid.
        if (!Verify())
        {
            return;
        }
        
        // Build the server.
        Logger.Debug("Preparing web server.");
        var builder = WebApplication.CreateBuilder();
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
        await app.RunAsync($"http://*:{Port}");
    }
}