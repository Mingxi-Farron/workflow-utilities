---
name: mode-control
version: "2.0.0"
description: "Switch permission mode (AUTO/TEST/SUPERVISED) by editing .claude/settings.local.json"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---

# Mode Control - Tool Permission Management

Switch between AUTO, TEST, and SUPERVISED permission modes by directly editing `.claude/settings.local.json`.

## Trigger Conditions

- User calls `/mode` command
- User natural language mode switch (see below)

## Natural Language Triggers

### Query Mode
- "what mode" / "current mode" / "当前模式" / "什么模式"

### Switch to AUTO
- "auto mode" / "fully automatic" / "approve all" / "全自动" / "不用确认了" / "全部放行"

### Switch to TEST
- "test mode" / "debug mode" / "ask for everything" / "测试模式" / "每步都确认" / "全部询问"

### Switch to SUPERVISED
- "supervised mode" / "normal mode" / "监督模式" / "正常模式"

---

## Mode Definitions

### AUTO Mode
- **Description**: All tool calls auto-approved, zero user confirmation
- **Use case**: Mature workflows, batch processing, trusted environment

### TEST Mode
- **Description**: Only read-only tools auto-approved, everything else requires confirmation
- **Use case**: Debugging, new workflow validation, security-sensitive tasks

### SUPERVISED Mode
- **Description**: Balanced permissions from `config/plugin_config.yaml` defaults or user backup
- **Use case**: Daily production, balance efficiency and safety

---

## Execution Logic

### Show Current Mode

1. Read `.claude/settings.local.json`
2. Check `permissions.allow` contents:
   - Contains bare `"Bash"` (no pattern) → **AUTO**
   - Contains only `["Read", "Glob", "Grep"]` → **TEST**
   - Otherwise → **SUPERVISED**
3. Display current mode and brief summary

### Switch to AUTO

**Goal: Zero approval prompts for any tool call.**

1. Read `.claude/settings.local.json`
2. Save current `permissions` object to `.claude/mode_backup.json` as backup
3. Replace `permissions` with:

```json
{
  "permissions": {
    "allow": [
      "Bash",
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep",
      "WebSearch",
      "WebFetch",
      "Agent",
      "Skill",
      "NotebookEdit",
      "EnterPlanMode",
      "ExitPlanMode",
      "EnterWorktree",
      "TaskCreate",
      "TaskUpdate",
      "TaskList",
      "TaskGet",
      "AskUserQuestion",
      "ToolSearch",
      "ListMcpResourcesTool",
      "ReadMcpResourceTool"
    ],
    "deny": []
  }
}
```

4. Keep all other fields in `settings.local.json` unchanged
5. Confirm: "AUTO mode activated. All tool calls auto-approved."

### Switch to TEST

**Goal: Maximum confirmation — only read-only tools pass through.**

1. Read `.claude/settings.local.json`
2. Save current `permissions` object to `.claude/mode_backup.json` as backup
3. Replace `permissions` with:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": []
  }
}
```

4. Keep all other fields unchanged
5. Confirm: "TEST mode activated. Only Read/Glob/Grep auto-approved."

### Switch to SUPERVISED

1. Check if `.claude/mode_backup.json` exists
   - **Yes** → Read backup, restore `permissions` to `.claude/settings.local.json`
   - **No** → Load defaults from `config/plugin_config.yaml` `supervised_defaults` section, or use fallback:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep",
      "WebSearch",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git branch:*)",
      "Bash(ls:*)",
      "Bash(mkdir:*)",
      "Bash(cp:*)"
    ],
    "deny": []
  }
}
```

2. Delete `.claude/mode_backup.json` after restore
3. Confirm: "SUPERVISED mode activated. Dangerous operations require confirmation."

---

## Key Insight: Bare Tool Names vs Patterns

**CRITICAL**: AUTO mode uses bare tool names (`"Bash"` not `"Bash(git *)"`) to match ALL invocations of that tool. Pattern-based entries like `"Bash(git status:*)"` require exact matches and will NOT auto-approve other commands.

- `"Bash"` → matches ANY bash command (auto-approve all)
- `"Bash(git status:*)"` → matches ONLY `git status` commands

This is why AUTO mode must use bare names, and SUPERVISED mode uses patterns for granular control.

---

## Important Notes

- Changes to `.claude/settings.local.json` take effect immediately in the current session
- The git-guard hook may still intercept `git commit`/`git push` separately — this is by design for safety
- Projects can add MCP tool permissions to the AUTO list as needed (e.g., `"mcp__clipboard__read"`)
- SUPERVISED defaults can be customized per-project via `config/plugin_config.yaml`
