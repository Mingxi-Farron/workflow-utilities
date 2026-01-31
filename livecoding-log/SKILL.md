---
name: livecoding-log
version: "1.0.0"
description: Check Unreal Engine Live Coding compilation logs for errors and status. Supports both project logs and global UE logs.
user-invocable: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# Live Coding Log - UE5 Compilation Status Checker

Check Unreal Engine Live Coding compilation logs for errors and status.

## Trigger Conditions

- User asks about Live Coding status
- User calls `/livecoding` command
- User mentions compilation errors
- After code changes that require Live Coding

## Natural Language Understanding

### Check Logs (zh)
- "查看 livecoding"
- "编译日志"
- "有没有编译错误"
- "livecoding 状态"
- "热重载日志"
- "检查编译"

### Check Logs (en)
- "check livecoding"
- "compilation log"
- "any compile errors"
- "livecoding status"
- "hot reload log"
- "check compile"

## Log Locations

### Project Log (Primary)
```
{ProjectDir}/Saved/Logs/{ProjectName}.log
```
Example: `C:/rph/water2026_demo/water2026/Saved/Logs/water2026.log`

### Global UE Log (Fallback)
```
C:/Users/{Username}/AppData/Local/UnrealEngine/5.7/Saved/Logs/Unreal.log
```

## Execution Steps

### Step 1: Find Project Log
```
1. Glob for *.log in {ProjectDir}/Saved/Logs/
2. Identify the main project log (not backup files)
3. If not found, use global UE log
```

### Step 2: Search for Live Coding Entries
```
1. Grep for "LogLiveCoding" in log file
2. Also search for "Error|error|Build|Compile|Patch"
3. Focus on recent entries (last 200 lines)
```

### Step 3: Parse Results
```
Key patterns to identify:
- "Starting Live Coding compile" → Compile started
- "Successfully initialized" → LC ready
- "Live coding failed" → Compilation error
- "Reload/Re-instancing Complete" → Success/Failure indicator
- "No object changes detected" → No changes applied
```

### Step 4: Report Status

#### Success Format
```
Live Coding Status: SUCCESS
Time: {timestamp}
Changes: {object changes or "No changes"}
```

#### Failure Format
```
Live Coding Status: FAILED
Time: {timestamp}
Error: See Live Coding Console for details

Common causes:
- Missing module dependency in Build.cs
- Syntax error in code
- Header changes requiring full rebuild
```

## Output Schema

```yaml
status: "success | failed | not_found | initializing"
timestamp: "Last compile time"
message: "Status description"
errors: ["List of error messages if any"]
suggestions: ["Possible fixes"]
```

## Quick Reference

| Log Pattern | Meaning |
|-------------|---------|
| `Starting LiveCoding` | Compile triggered |
| `Successfully initialized` | LC server ready |
| `Live coding failed` | Compile error |
| `Reload/Re-instancing Complete` | Patch applied |
| `No object changes detected` | Nothing to patch |

## Notes

- Detailed errors are shown in **Live Coding Console** window, not in main log
- Build.cs changes require full rebuild, not Live Coding
- Header-only changes may require editor restart
