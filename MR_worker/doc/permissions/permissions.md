# Permissions

Users have different abilities depending on the access level they have in a particular group or project.

If a user is both in a project group and in the project itself, the highest permission level is used.

If a user is a GitLab administrator they receive all permissions.

## Project

| Action                                | Guest   | Reporter   | Developer   | Master   | Owner  |
|---------------------------------------|---------|------------|-------------|----------|--------|
| Create new issue                      | ✓       | ✓          | ✓           | ✓        | ✓      |
| Leave comments                        | ✓       | ✓          | ✓           | ✓        | ✓      |
| Pull project code                     |         | ✓          | ✓           | ✓        | ✓      |
| Download project                      |         | ✓          | ✓           | ✓        | ✓      |
| Create code snippets                  |         | ✓          | ✓           | ✓        | ✓      |
| Create new merge request              |         |            | ✓           | ✓        | ✓      |
| Create new branches                   |         |            | ✓           | ✓        | ✓      |
| Push to non-protected branches        |         |            | ✓           | ✓        | ✓      |
| Force push to non-protected branches  |         |            | ✓           | ✓        | ✓      |
| Remove non-protected branches         |         |            | ✓           | ✓        | ✓      |
| Add tags                              |         |            | ✓           | ✓        | ✓      |
| Write a wiki                          |         |            | ✓           | ✓        | ✓      |
| Manage issue tracker                  |         |            | ✓           | ✓        | ✓      |
| Manage labels                         |         |            | ✓           | ✓        | ✓      |
| Create new milestones                 |         |            |             | ✓        | ✓      |
| Add new team members                  |         |            |             | ✓        | ✓      |
| Push to protected branches            |         |            |             | ✓        | ✓      |
| Enable/disable branch protection      |         |            |             | ✓        | ✓      |
| Turn on/off prot. branch push for devs|         |            |             | ✓        | ✓      |
| Rewrite/remove git tags               |         |            |             | ✓        | ✓      |
| Edit project                          |         |            |             | ✓        | ✓      |
| Add deploy keys to project            |         |            |             | ✓        | ✓      |
| Configure project hooks               |         |            |             | ✓        | ✓      |
| Switch visibility level               |         |            |             |          | ✓      |
| Transfer project to another namespace |         |            |             |          | ✓      |
| Remove project                        |         |            |             |          | ✓      |
| Force push to protected branches      |         |            |             |          |        |
| Remove protected branches             |         |            |             |          |        |

## Group

| Action                  | Guest | Reporter | Developer | Master | Owner |
|-------------------------|-------|----------|-----------|--------|-------|
| Browse group            | ✓     | ✓        | ✓         | ✓      | ✓     |
| Edit group              |       |          |           |        | ✓     |
| Create project in group |       |          |           | ✓      | ✓     |
| Manage group members    |       |          |           |        | ✓     |
| Remove group            |       |          |           |        | ✓     |

Any user can remove themselves from a group, unless they are the last Owner of the group.
