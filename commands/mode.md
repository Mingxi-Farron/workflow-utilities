---
description: "Control tool call permission levels"
argument-hint: "[AUTO|TEST|SUPERVISED] or [allow|deny {tool}] or [list]"
---

# /mode - Mode Control Command

Control tool call permission levels and switch between automation modes.

## Usage

```
/mode                      # Show current mode and permissions
/mode AUTO                 # Switch to AUTO mode (all auto-approved)
/mode TEST                 # Switch to TEST mode (most require confirmation)
/mode SUPERVISED           # Switch to SUPERVISED mode (customizable)
/mode allow {tool}         # Add tool to auto-approve list (SUPERVISED only)
/mode deny {tool}          # Remove tool from auto-approve list (SUPERVISED only)
/mode list                 # List current permission configuration
```

## Modes

| Mode | Description |
|------|-------------|
| AUTO | All tool calls auto-approved |
| TEST | Only Read/Glob/Grep auto-approved, others require confirmation |
| SUPERVISED | User-customizable permissions |

## Tool Pattern Syntax

```
Read                    # All Read operations
Bash                    # All Bash operations
Bash(git *)             # Git-related commands
Bash(git status)        # Specific command
Edit(*.md)              # Edit markdown files
Write(output/*)         # Write to output directory
```

## Implementation

Calls `skills/mode_control.md` for execution logic.
