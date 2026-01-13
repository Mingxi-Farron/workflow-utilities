# Mode Control - Tool Permission Management

Control Claude Code tool call permission levels through three modes.

## Trigger Conditions

- Agent startup (auto-read configuration)
- User natural language mode switch
- User calls `/mode` command
- User modifies permissions in SUPERVISED mode

## Natural Language Understanding

### Query Mode (zh)
- "现在什么模式"
- "当前模式"
- "哪个模式"
- "什么权限"

### Query Mode (en)
- "what mode"
- "current mode"
- "which mode"
- "what permissions"

### Switch to AUTO (zh)
- "切换到自动"
- "用自动模式"
- "全自动"
- "不用确认了"
- "全部放行"

### Switch to AUTO (en)
- "switch to auto"
- "auto mode"
- "fully automatic"
- "approve all"

### Switch to TEST (zh)
- "切换到测试"
- "用测试模式"
- "调试模式"
- "每步都确认"
- "全部询问"

### Switch to TEST (en)
- "switch to test"
- "test mode"
- "debug mode"
- "ask for everything"

### Switch to SUPERVISED (zh)
- "切换到监督"
- "监督模式"
- "正常模式"

### Switch to SUPERVISED (en)
- "switch to supervised"
- "supervised mode"
- "normal mode"

### Modify Permissions (zh)
- "允许 {tool}"
- "禁止 {tool}"
- "添加自动批准 {tool}"
- "移除自动批准 {tool}"

### Modify Permissions (en)
- "allow {tool}"
- "deny {tool}"
- "auto approve {tool}"
- "remove auto approve {tool}"

## Mode Definitions

### AUTO Mode
- **Description**: All tool calls auto-approved
- **Permissions**: `auto_approve: ["*"]`
- **Use case**: Mature workflows, batch processing, trusted environment

### TEST Mode
- **Description**: Almost all tool calls require confirmation
- **Permissions**:
  - `auto_approve: ["Read", "Glob", "Grep"]`
  - `require_confirm: ["*"]`
- **Use case**: Debugging, new workflow validation, security-sensitive

### SUPERVISED Mode
- **Description**: User-customizable permissions
- **Permissions**:
  - `auto_approve`: Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, git status/diff/log, npm test/build
  - `require_confirm`: git commit/push, rm, mv
- **Customizable**: Yes
- **Use case**: Daily production, balance efficiency and safety

## Execution Logic

### On Startup
```
1. Read .claude/settings.json
2. Read .claude/mode_state.json
3. Apply current mode permissions
```

### On Mode Switch
```
1. Load target mode permission template
2. Write to .claude/settings.json
3. Save current mode to mode_state.json
4. Notify user
```

### On Permission Modify (SUPERVISED only)
```
1. Verify current mode is SUPERVISED
2. Parse tool name and pattern
3. Update auto_approve or require_confirm list
4. Write to .claude/settings.json
5. Sync mode_state.json
6. Notify user
```

## Tool Pattern Syntax

```
Read                    # All Read operations
Bash                    # All Bash operations
Bash(git *)             # Git-related commands
Bash(git status)        # Specific command
Bash(npm *)             # NPM-related commands
Edit(*.md)              # Edit markdown files
Edit(src/**/*.ts)       # Edit ts files in src
Write(output/*)         # Write to output directory
```

## Message Templates

Uses `messages/{language}.json` keys:
- `mode_control.current`
- `mode_control.switched`
- `mode_control.auto_desc`
- `mode_control.test_desc`
- `mode_control.supervised_desc`
- `mode_control.permission_added`
- `mode_control.permission_removed`
