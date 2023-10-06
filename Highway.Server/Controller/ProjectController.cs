using Highway.Server.Model.Project;
using Highway.Server.Model.Response;
using Highway.Server.Model.State;
using Highway.Server.Util;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;

namespace Highway.Server.Controller;

public class ProjectController : ControllerBase
{
    [HttpGet]
    [Route("/project/manifest")]
    public ObjectResult GetProjectManifest()
    {
        return new ProjectManifestResponse()
        {
            Manifest = FileUtil.Get<Manifest>(FileUtil.FindFileInParent(FileUtil.ProjectFileName))!,
        }.ToObjectResult(200);
    }
    
    [HttpGet]
    [Route("/project/hashes")]
    public async Task<ObjectResult> GetProjectHashes()
    {
        var hashesFilePath = FileUtil.FindFileInParent(FileUtil.HashesFileName);
        var hashCollection = (hashesFilePath == null ? new ScriptHashCollection() : JsonConvert.DeserializeObject<ScriptHashCollection>(await System.IO.File.ReadAllTextAsync(hashesFilePath)));
        return new FileListHashesResponse()
        {
            Hashes = hashCollection,
        }.ToObjectResult(200);
    }
}