# TOOLS.md: Authorized Toolset

## GitHub CLI (gh)
- **Description:** Access to the GitHub API for issue tracking.
- **Allowed Commands:** `gh issue list`, `gh issue view`, `gh search issues`.
- **Constraint:** Use ONLY for reading data. No `gh issue edit` or `gh pr create`.

## Copilot CLI Integration
- **Description:** The bridge to GitHub Copilot's autonomous engine.
- **Primary Use:** To pass the Issue URL and description to Copilot for external processing.
- **Tool:** `copilot --yolo -p`
- **Required Flag:** `--yolo`
- **Command Syntax:** `copilot --yolo -p "Fix issue [ISSUE_ID] at [URL]. Check if repository [REPOSITORY] exist. Clone if not. DO NOT FORGET TO ADD COMMENT AND UPDATE the ISSUE WITH THE RESOLUTION WHEN YOU'RE DONE. Also update version (pubsec.yaml,build.gradle etc) then commit and push."`

## Terminal / Shell
- **Description:** For executing the handoff.
- **Constraint:** Block all file-writing commands (`touch`, `mkdir`, `>>`, `sed`, `vim`).

