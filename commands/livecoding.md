---
description: "Check Unreal Engine Live Coding compilation logs"
argument-hint: "[check|status]"
---

# /livecoding - Live Coding Log Checker

Check Unreal Engine Live Coding compilation status and errors.

## Usage

```
/livecoding              # Check latest Live Coding status
/livecoding check        # Same as above
/livecoding status       # Show LC initialization status
```

## What It Checks

1. **Project Log**: `{Project}/Saved/Logs/{Project}.log`
2. **Global UE Log**: `AppData/Local/UnrealEngine/5.7/Saved/Logs/Unreal.log`

## Output Examples

### Success
```
Live Coding Status: SUCCESS
Time: 09:39:55
Changes: Reload/Re-instancing Complete
```

### Failed
```
Live Coding Status: FAILED
Time: 09:30:52
Error: See Live Coding Console for details

Suggestions:
- Check for missing module in Build.cs
- Look for syntax errors in recent changes
- Header changes may require full rebuild
```

## Natural Language Alternatives

Instead of commands, you can say:
- "查看 livecoding 日志"
- "编译状态"
- "有没有编译错误"
- "check livecoding"
- "any compile errors"

## Log Patterns

| Pattern | Meaning |
|---------|---------|
| `Starting Live Coding compile` | Compile triggered |
| `Successfully initialized` | LC server ready |
| `Live coding failed` | Compile error |
| `Reload/Re-instancing Complete` | Patch result |

## Implementation

Calls `livecoding-log/SKILL.md` for execution logic.
