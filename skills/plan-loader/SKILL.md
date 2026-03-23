---
name: plan-loader
version: "1.0.0"
description: "Auto-resume plan implementation sessions by injecting handoff/plan context on SessionStart."
user-invocable: false
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# Plan Loader - Implementation Session Auto-Resume

Automatically injects the latest handoff or plan context when starting an implementation session, so Claude picks up where the previous session left off.

## How It Works

The hook runs on **SessionStart** (new session, `/clear`, compaction). It checks three gates in order:

### Gate 1: Session Type

Only activates when `CLAUDE_SESSION_TYPE=impl`. Without this environment variable, the hook exits immediately. This prevents accidental plan injection in normal sessions.

**Start an impl session:**
```bash
CLAUDE_SESSION_TYPE=impl claude
```

### Gate 2: Active Handoff (in-progress or NOT STARTED)

Searches `.claude/docs/handoff/*.md` for the most recent file with `**Status:** in-progress` or `**Status:** NOT STARTED`. If found:
- Injects the full handoff contents via `<impl-session>` tag
- Instructs Claude to read the referenced plan file, then continue from Next Steps

### Gate 3: Approved Plan (First Session)

If no in-progress handoff exists, searches `.claude/docs/plan/*.md` for the most recent file containing `approved`. If found:
- Injects a summary (status, step headings, acceptance criteria)
- Instructs Claude to read the full plan and start from Step 1

### No Match

If neither a handoff nor a plan is found, the hook exits silently (no context injected).

## Installation

Copy `plan-loader.sh` to your project's `.claude/hooks/` directory:

```bash
cp workflow-utilities/scripts/plan-loader.sh .claude/hooks/plan-loader.sh
```

Register in `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/plan-loader.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## Workflow Integration

This hook completes the plan/handoff lifecycle:

```
/plan <task>          → Creates plan in .claude/docs/plan/
                        User approves → Status: approved

CLAUDE_SESSION_TYPE=impl claude
                      → plan-loader injects plan context
                        Claude implements Step 1, 2, ...

/handoff <task>       → Saves progress to .claude/docs/handoff/
                        Status: in-progress

CLAUDE_SESSION_TYPE=impl claude  (next session)
                      → plan-loader injects handoff context
                        Claude resumes from Next Steps

/plan --progress      → Updates plan status tags
                        All done → Status: completed
```

## Design Notes

- **Zero noise** — does nothing in normal sessions (no `CLAUDE_SESSION_TYPE`)
- **Handoff priority** — handoffs take precedence over plans (Gate 2 before Gate 3), matching both `in-progress` and `NOT STARTED` statuses
- **Summary injection** — for plans, only injects step headings and criteria (not full content), keeping the context tag compact. Claude reads the full file via the Read tool.
- **Idempotent** — safe to re-trigger on `/clear` or compaction; always reads the latest state from disk
