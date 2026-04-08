# HEARTBEAT.md Template

```markdown
# Keep this file empty (or with only comments) to skip heartbeat API calls.

# Add tasks below when you want the agent to check something periodically.
```

## Schedule: Hourly
1. Run `gh issue list` for the user in `USER.md`.
2. For each issue not yet in `MEMORY.md`:
    - Generate the Copilot CLI command.
    - Log the issue ID to `MEMORY.md` to avoid duplicates.
    - Output the command to the terminal/bridge.
