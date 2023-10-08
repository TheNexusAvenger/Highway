# Highway
*For when it is "My way or the highway" for Roblox Studio code workflows.*

Highway provides the ability to work on Roblox Studio projects when the project
is not set up to use external editors. It is intended for teams that refuse
to use collaborative editing or other commit-based workflows.

**Treat this as a tool of last resort.** While it works, it should only be
remotely considered if:
1. "Collaborative Editing" within Roblox Studio is not an option.
2. Rojo is not an option.
3. Multiple programmers are on at any given time, causing conflicts.

In addition, **do not mix with Rojo or other tools**. While the file extensions
may be the same, mixing with Rojo may cause data loss.

## Workflow
When working on a change, this is the recommended workflow, where "Game A" is
the shared Team Create instance and "Game B" is a version you control:
1. Using the plugin, push the changes from "Game A" to the remote Git repository.
2. Merge the changes with any relevant branches, or branch off from the pushed changes.
3. Work on any changes, optionally with live syncing to "Game B" using the plugin.
4. Before merging changes to "Game A", use the plugin to push changes to the remote.
5. Merge the local branch with the updated Git remote.
6. Using the plugin, pull in the changes to "Game A".

## Files
### `highway.json`
This JSON file is used to configure the server. It can have the following:
- `name: string`: Display name of the project *(not used at the moment)*.
- `pushPlaceId: number`: Optional place id to require for pulling/pushing changes.
- `syncPlaceId: number`: Optional place id to require for live syncing changes.
- `git.checkoutBranch: string` *(Required)*: Default branch to check out from the remote when pushing from Roblox Studio.
- `git.pushBranch: string` *(Required)*: Default branch to push to the remote when pushing from Roblox Studio.
- `git.commitMessage: string`: Default custom commit message when committing changes from Roblox Studio.
- `paths: {[string]: string}` *(Required)*: Map of the Studio instance paths to the directories to store the files.

For safety, `pushPlaceId` and `syncPlaceId` are both recommended and should
not be the same. `checkoutBranch` and `pushBranch` can be the same or different.
Below is an example.

```json
{
    "name": "My Project",
    "pushPlaceId": 12345,
    "syncPlaceId": 23456,
    "git": {
        "checkoutBranch": "master",
        "pushBranch": "upstream-merge",
        "commitMessage": "My custom commit message",
    },
    "paths": {
        "ReplicatedStorage": "src/ReplicatedStorage",
        "ServerStorage.Folder1": "src/ServerStorage/Folder1",
        "ServerStorage.Folder2": "src/ServerStorage/Folder2",
        "ServerStorage.Folder3.Folder4": "src/Custom",
        "TestService": "test"
    }
}
```

### `highway-hashes.json`
This file is generated when a push from Roblox Studio is done. It is used
during the pull process to ensure the changes made to the scripts are based
on the latest version. **Do not add this file to your gitignore, and do not
manually modify it.**

## License
Highway is available under the terms of the GNU Lesser General Public
License. See [LICENSE](LICENSE) for details.