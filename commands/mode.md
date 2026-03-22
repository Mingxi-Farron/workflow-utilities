---
description: "Switch permission mode (AUTO/TEST/SUPERVISED)"
argument-hint: "[AUTO|TEST|SUPERVISED] or [list]"
---

# /mode - Permission Mode Control

Switch between AUTO, TEST, and SUPERVISED permission modes by directly editing `.claude/settings.local.json`.

## Usage

```
/mode                      # Show current mode and permissions
/mode AUTO                 # All tools auto-approved, zero prompts
/mode TEST                 # Only Read/Glob/Grep auto-approved
/mode SUPERVISED           # Restore balanced permissions (from backup or defaults)
/mode list                 # List current permission configuration
```

## Modes

| Mode | Description | Auto-Approved |
|------|-------------|---------------|
| AUTO | Zero confirmation prompts | All tools (bare names) |
| TEST | Maximum confirmation | Read, Glob, Grep only |
| SUPERVISED | Balanced, customizable | Per `plugin_config.yaml` |

## Implementation

Calls `mode-control/SKILL.md` for execution logic.
