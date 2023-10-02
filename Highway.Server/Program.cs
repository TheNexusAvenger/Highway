using System.CommandLine;
using Highway.Server.Model.Project;
using Highway.Server.Model.State;
using Highway.Server.Util;
using Microsoft.AspNetCore.Diagnostics;
using Newtonsoft.Json;

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
        
        // Return if there is no project file or it is invalid.
        var projectFilePath = FileUtil.FindFileInParent(FileUtil.ProjectFileName);
        if (projectFilePath == null)
        {
            Logger.Warn($"Project file {FileUtil.ProjectFileName} not found in the current directory or parent directory.");
            return false;
        }
        try
        {
            // Verify the context exists.
            var projectContents = FileUtil.Get<Manifest>(projectFilePath);
            if (projectContents == null)
            {
                Logger.Warn($"Project file {FileUtil.ProjectFileName} could not be parsed.");
                return false;
            }
            
            // Verify the git configuration.
            var gitConfiguration = projectContents.Git;
            if (gitConfiguration == null)
            {
                Logger.Warn($"Project file {FileUtil.ProjectFileName} does not contain a \"git\" section.");
                return false;
            }
            if (gitConfiguration.CheckoutBranch == null)
            {
                Logger.Warn($"Project file {FileUtil.ProjectFileName}'s \"git\" section does not contain \"checkoutBranch\" (defines which branch is pulled from before pushing from Roblox Studio).");
                return false;
            }
            if (gitConfiguration.PushBranch == null)
            {
                Logger.Warn($"Project file {FileUtil.ProjectFileName}'s \"git\" section does not contain \"pushBranch\" (defines the branch to push to the git remote after being pushed from Roblox Studio).");
                return false;
            }
            
            // Verify the paths.
            if (projectContents.Paths == null)
            {
                Logger.Warn($"Project file {FileUtil.ProjectFileName} does not contain a \"paths\" section.");
                return false;
            }
        }
        catch (JsonReaderException exception)
        {
            // Handle JSON processing exceptions.
            Logger.Warn($"Project file {FileUtil.ProjectFileName} is not valid JSON: {exception.Message}");
            return false;
        }
        
        // Return if the hash file is corrupted.
        try
        {
            var scriptHashes = FileUtil.Get<ScriptHashCollection>(FileUtil.FindFileInParent(FileUtil.HashesFileName));
            if (scriptHashes != null && scriptHashes.Hashes == null)
            {
                Logger.Warn($"Hashes file {FileUtil.HashesFileName} is missing \"hashes\" section.");
                return false;
            }
        }
        catch (JsonReaderException exception)
        {
            // Handle JSON processing exceptions.
            Logger.Warn($"Hashes file file {FileUtil.HashesFileName} is not valid JSON: {exception.Message}");
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
            // TODO: Delay is a workaround for logs being threaded. Somehow fix in Nexus Logging.
            Task.Delay(100).Wait();
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