﻿using Highway.Server.Model.Project;
using Highway.Server.Model.Response;
using Highway.Server.Model.State;
using Highway.Server.Util;
using Microsoft.AspNetCore.Mvc;

namespace Highway.Server.Controller;

public class FileController : ControllerBase
{
    [HttpGet]
    [Route("/file/list/hashes")]
    public ObjectResult GetListHashes()
    {
        // Prepare tracking changes for future requests.
        DirectoryWatcher.Get();
        
        // Build the manifest list.
        var projectDirectory = FileUtil.GetProjectDirectory()!;
        var configuration = FileUtil.Get<Manifest>(FileUtil.FindFileInParent(FileUtil.ProjectFileName))!;
        var hashCollection = new ScriptHashCollection();
        foreach (var (baseScriptPath, basePath) in configuration.Paths!)
        {
            hashCollection.AddFileHashes(baseScriptPath.Replace('.', '/'), Path.Combine(projectDirectory, basePath));
        }
        
        // Create and return the response.
        return new FileListHashesResponse()
        {
            Hashes = hashCollection,
        }.ToObjectResult(200);
    }

    [HttpGet]
    [Route("/file/list/hashes/changes")]
    public ObjectResult GetListHashChanges()
    {
        // Get the changed files.
        var watcher = DirectoryWatcher.Get();
        var projectDirectory = FileUtil.GetProjectDirectory()!;
        var configuration = FileUtil.Get<Manifest>(FileUtil.FindFileInParent(FileUtil.ProjectFileName))!;
        var hashCollection = new ScriptHashCollection();
        var sentPaths = new List<string>();
        foreach (var (path, type) in watcher.ChangedFiles)
        {
            // Return a request to resync if the path is not a file or an existing directory.
            // Cases of renaming or deleting directories aren't handled well with the current design.
            if (!path.ToLower().EndsWith(".lua") && (type != DirectoryWatcher.ChangedFilePath.File || Directory.Exists(path)))
            {
                watcher.Reset();
                return new FileListHashesResponse()
                {
                    Resync = true,
                }.ToObjectResult(200);
            }
            
            // Add the script path.
            var scriptPath = configuration.GetScriptPathForPath(projectDirectory, path);
            if (scriptPath == null) continue;
            try
            {
                var scriptHash = System.IO.File.Exists(path) ? HashUtil.GetHash(System.IO.File.ReadAllText(path)) : "DELETED";
                hashCollection.Hashes!.Add(scriptPath, scriptHash);
                sentPaths.Add(path);
            }
            catch (IOException)
            {
                Logger.Warn($"Reading {path} failed. Changed hash will be sent as part of the next request.");
            }
        }

        // Clear the changes that were sent.
        foreach (var path in sentPaths)
        {
            watcher.ChangedFiles.Remove(path);
        }

        // Create and return the response.
        return new FileListHashesResponse()
        {
            Hashes = hashCollection,
        }.ToObjectResult(200);
    }

    [HttpGet]
    [Route("/file/read")]
    public ObjectResult GetFile(string? path)
    {
        // Return if there is no path.
        if (path == null)
        {
            return new BaseResponse()
            {
                Status = "MissingField",
                Message = "Missing \"path\" parameter.",
            }.ToObjectResult(400);
        }
        
        // Return if the file does not exist.
        var projectDirectory = FileUtil.GetProjectDirectory()!;
        var configuration = FileUtil.Get<Manifest>(FileUtil.FindFileInParent(FileUtil.ProjectFileName))!;
        var scriptFilePath = configuration.GetPathForScriptPath(projectDirectory, path);
        if (scriptFilePath == null || !System.IO.File.Exists(scriptFilePath))
        {
            return new BaseResponse()
            {
                Status = "FileNotFound",
                Message = $"File with script path \"{path}\" does not exist.",
            }.ToObjectResult(404);
        }
        
        // Return the script contents.
        return new FileReadResponse()
        {
            Contents = System.IO.File.ReadAllText(scriptFilePath),
        }.ToObjectResult(200);
    }
}