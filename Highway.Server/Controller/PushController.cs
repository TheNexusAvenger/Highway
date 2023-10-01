using System.Security;
using Highway.Server.Model.Request;
using Highway.Server.Model.Response;
using Highway.Server.Model.State;
using Highway.Server.State;
using Microsoft.AspNetCore.Mvc;

namespace Highway.Server.Controller;

public class PushController : ControllerBase
{
    [HttpPost]
    [Route("/push/session/start")]
    public ObjectResult PostStartSession([FromBody] ScriptHashCollection hashCollection)
    {
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
    public ObjectResult PostAddScript([FromBody] PushAddScriptRequest addScriptRequest)
    {
        // Return if there is a request issue.
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
    public ObjectResult PostCompleteSession([FromBody] PushCompleteRequest completeRequest)
    {
        // Return if there is a request issue.
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
            var rootScriptInstance = session.Complete();
            // TODO: Implement rest.
        }
        catch (KeyNotFoundException)
        {
            return new BaseResponse()
            {
                Status = "ScriptNotFound",
                Message = $"The script was not sent in the hash collection when creating the session.",
            }.ToObjectResult(404);
        }

        // Return success.
        return new BaseResponse()
        {
            Message = "Push complete.",
        }.ToObjectResult(200);
    }
}