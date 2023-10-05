using System.Security;
using Highway.Server.Model.Project;
using Highway.Server.Model.Request;
using Highway.Server.Model.Response;
using Highway.Server.Model.State;
using Highway.Server.State;
using Highway.Server.Util;
using Microsoft.AspNetCore.Mvc;

namespace Highway.Server.Controller;

public class PushController : ControllerBase
{
    [HttpPost]
    [Route("/push/session/start")]
    public ObjectResult PostStartSession([FromBody] ScriptHashCollection? hashCollection)
    {
        // Return if there is a request issue.
        if (hashCollection == null)
        {
            return new BaseResponse()
            {
                Status = "MissingBody",
                Message = "Body was not sent or could not be parsed.",
            }.ToObjectResult(400);
        }
        if (hashCollection.Hashes == null)
        {
            return new BaseResponse()
            {
                Status = "MissingField",
                Message = "Missing \"hashes\" field.",
            }.ToObjectResult(400);
        }
        
        // Start the session.
        var session = PushSession.Create(hashCollection);

        // Return the response for the created session.
        return new BaseSessionResponse()
        {
            Message = "Session is started.",
            Session = session.Id,
        }.ToObjectResult(200);
    }
    
    [HttpPost]
    [Route("/push/session/add")]
    public ObjectResult PostAddScript([FromBody] PushAddScriptRequest? addScriptRequest)
    {
        // Return if there is a request issue.
        if (addScriptRequest == null)
        {
            return new BaseResponse()
            {
                Status = "MissingBody",
                Message = "Body was not sent or could not be parsed.",
            }.ToObjectResult(400);
        }
        if (addScriptRequest.Session == null)
        {
            return new BaseResponse()
            {
                Status = "MissingField",
                Message = "Missing \"session\" field.",
            }.ToObjectResult(400);
        }
        if (addScriptRequest.ScriptPath == null)
        {
            return new BaseResponse()
            {
                Status = "MissingField",
                Message = "Missing \"scriptPath\" field.",
            }.ToObjectResult(400);
        }
        if (addScriptRequest.Contents == null)
        {
            return new BaseResponse()
            {
                Status = "MissingField",
                Message = "Missing \"contents\" field.",
            }.ToObjectResult(400);
        }
        
        // Return if the session does not exist.
        var session = PushSession.Get(addScriptRequest.Session);
        if (session == null)
        {
            return new BaseResponse()
            {
                Status = "SessionNotFound",
                Message = $"The push session does not exist.",
            }.ToObjectResult(404);
        }
        
        // Add the script.
        try
        {
            session.Add(addScriptRequest.ScriptPath, addScriptRequest.Contents);
        }
        catch (KeyNotFoundException)
        {
            return new BaseResponse()
            {
                Status = "ScriptNotFound",
                Message = $"The script was not sent in the hash collection when creating the session.",
            }.ToObjectResult(404);
        }
        catch (SecurityException)
        {
            return new BaseResponse()
            {
                Status = "ScriptHashError",
                Message = $"The script source does not match the hash sent in the hash collection.",
            }.ToObjectResult(409);
        }
        
        // Return success.
        return new BaseResponse()
        {
            Message = "Script added.",
        }.ToObjectResult(200);
    }
    
    [HttpPost]
    [Route("/push/session/complete")]
    public async Task<ObjectResult> PostCompleteSession([FromBody] PushCompleteRequest? completeRequest)
    {
        // Return if there is a request issue.
        if (completeRequest == null)
        {
            return new BaseResponse()
            {
                Status = "MissingBody",
                Message = "Body was not sent or could not be parsed.",
            }.ToObjectResult(400);
        }
        if (completeRequest.Session == null)
        {
            return new BaseResponse()
            {
                Status = "MissingField",
                Message = "Missing \"session\" field.",
            }.ToObjectResult(400);
        }
        
        // Return if the session does not exist.
        var session = PushSession.Get(completeRequest.Session);
        if (session == null)
        {
            return new BaseResponse()
            {
                Status = "SessionNotFound",
                Message = $"The push session does not exist.",
            }.ToObjectResult(404);
        }
        
        // Complete the push.
        try
        {
            // Complete the session.
            session.Complete();
            
            // Prepare the git branch.
            var gitProcess = await GitProcess.GetCurrentProcess().ForkAsync();
            var configuration = FileUtil.Get<Manifest>(FileUtil.FindFileInParent(FileUtil.ProjectFileName))!;
            var gitConfiguration = configuration.Git;
            var fetchReturnCode = await gitProcess.RunCommandAsync("fetch");
            if (fetchReturnCode != 0)
            {
                return new BaseResponse()
                {
                    Status = "PushFetchError",
                    Message = $"Performing \"git fetch\" on the forked git process failed with non-zero return code {fetchReturnCode}",
                }.ToObjectResult(500);
            }
            var checkoutBranch = completeRequest.CheckoutBranch ?? gitConfiguration.CheckoutBranch;
            var checkoutReturnCode = await gitProcess.RunCommandAsync($"checkout \"{checkoutBranch}\"");
            if (checkoutReturnCode != 0)
            {
                return new BaseResponse()
                {
                    Status = "PushCheckoutError",
                    Message = $"Performing \"git checkout \"{checkoutBranch}\" on the forked git process failed with non-zero return code {checkoutReturnCode}",
                }.ToObjectResult(500);
            }
            
            // Update the files.
            await session.WriteFilesAsync(gitProcess.GitPath, configuration);
            
            // Commit and push the changes.
            await gitProcess.RunCommandAsync("add .");
            var commitMessage = completeRequest.CommitMessage ?? gitConfiguration.CommitMessage ?? "Update from Roblox Studio.";
            var commitReturnCode = await gitProcess.RunCommandAsync($"commit -m \"{commitMessage}\"");
            if (commitReturnCode != 0)
            {
                return new BaseResponse()
                {
                    Status = "PushCommitError",
                    Message = $"Performing \"git commit\" on the forked git process failed with non-zero return code {commitReturnCode}",
                }.ToObjectResult(500);
            }
            // TODO: Remove hard-coded "origin" remote.
            var pushBranch = completeRequest.PushBranch ?? gitConfiguration.PushBranch;
            var pushReturnCode = await gitProcess.RunCommandAsync($"push origin HEAD:\"{pushBranch}\"");
            if (pushReturnCode != 0)
            {
                return new BaseResponse()
                {
                    Status = "PushError",
                    Message = $"Performing \"git push origin HEAD:{pushBranch}\" on the forked git process failed with non-zero return code {pushReturnCode}",
                }.ToObjectResult(500);
            }
        }
        catch (KeyNotFoundException)
        {
            return new BaseResponse()
            {
                Status = "SessionIncomplete",
                Message = $"At least 1 script was not added to the session.",
            }.ToObjectResult(400);
        }

        // Return success.
        return new BaseResponse()
        {
            Message = "Push complete.",
        }.ToObjectResult(200);
    }
}