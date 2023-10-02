using Highway.Server.Model.Project;
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
        // Build the manifest list.
        var projectDirectory = FileUtil.GetParentDirectoryOf(FileUtil.GitDirectoryName)!;
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
        var projectDirectory = FileUtil.GetParentDirectoryOf(FileUtil.GitDirectoryName)!;
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
            Contents = System.IO.File.ReadAllText(path),
        }.ToObjectResult(200);
    }
}