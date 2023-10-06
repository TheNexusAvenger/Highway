--[[
TheNexusAvenger

Common methods for performing HTTP actions.
--]]
--!strict

local HttpService = game:GetService("HttpService")

local Types = require(script.Parent.Parent:WaitForChild("Types"))

local CommonAction = {}
CommonAction.__index = CommonAction

export type RobloxHttpResponse<T> = {
    Success: boolean,
    StatusCode: number,
    StatusMessage: string,
    Headers: {[string]: string},
    Body: T,
}

export type CommonAction = {
    new: () -> (CommonAction),
    PerformRequest: (self: CommonAction, Method: string, Url: string, Body: any?) -> (RobloxHttpResponse<string>),
    PerformRequestOrError: (self: CommonAction, Method: string, Url: string, Body: any?) -> (RobloxHttpResponse<string>),
    GetProjectManifest: (self: CommonAction) -> (Types.ProjectManifest),
    GetFileHashes: (self: CommonAction, Endpoint: string?) -> (Types.FileHashes),
    GetSource: (self: CommonAction, Path: string) -> (string),
}



--[[
Creates a CommonAction instance.
--]]
function CommonAction.new(): CommonAction
    return (setmetatable({}, CommonAction) :: any) :: CommonAction
end

--[[
Performs an HTTP request. Returns the response.
--]]
function CommonAction:PerformRequest(Method: string, Url: string, Body: any?): RobloxHttpResponse<string>
    return HttpService:RequestAsync({
        Url = "http://127.0.0.1:22894"..Url,
        Method = Method,
        Headers = {
            ["Content-Type"] = (Body and "application/json" or nil),
        },
        Body = (Body and HttpService:JSONEncode(Body) or nil),
    })
end

--[[
Performs an HTTP request and throws an error if the request returned a non-success HTTP status code.
--]]
function CommonAction:PerformAndParseRequest(Method: string, Url: string, Body: any?): RobloxHttpResponse<any>
    local Response = self:PerformRequest(Method, Url, Body)
    Response.Body = HttpService:JSONDecode(Response.Body)
    if not Response.Success then
        error("HTTP "..tostring(Response.StatusCode).." - "..tostring(Response.Body.status)..": "..tostring(Response.Body.message))
    end
    return Response
end

--[[
Fetches the current project configuration.
--]]
function CommonAction:GetProjectManifest(): Types.ProjectManifest
    local Response = self:PerformAndParseRequest("GET", "/project/manifest").Body["manifest"]
    local Paths = {}
    for ScriptPath, FilePath in Response.paths do
        local NewScriptPath, _ = string.gsub(ScriptPath, "%.", "/")
        Paths[NewScriptPath] = FilePath
    end
    return {
        Name = Response.name,
        PushPlaceId = Response.pushPlaceId,
        SyncPlaceId = Response.syncPlaceId,
        Git = {
            CheckoutBranch = Response.git.checkoutBranch,
            PushBranch = Response.git.pushBranch,
            CommitMessage = Response.git.commitMessage,
        },
        Paths = Paths,
    }
end

--[[
Fetches the current hashes of the file system.
--]]
function CommonAction:GetFileHashes(Endpoint: string?): Types.FileHashes
    local Response = self:PerformAndParseRequest("GET", Endpoint or "/file/list/hashes").Body["hashes"]
    return {
        HashMethod = Response.hashMethod,
        Hashes = Response.hashes,
    }
end

--[[
Fetches the source of a script.
--]]
function CommonAction:GetSource(Path: string): string
    return self:PerformAndParseRequest("GET", "/file/read?path="..Path).Body.contents
end



return (CommonAction :: any) :: CommonAction