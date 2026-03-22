---
description: "Create a concise handoff file for unfinished tasks"
argument-hint: "<task-name> | --read"
---

# /handoff - Task Handoff Command

Create handoff documents for unfinished tasks, or read the latest one.

## Usage

```
/handoff <task-name>       # Create a new handoff file
/handoff --read            # Read the latest handoff file
```

## What It Captures

- Goal, status, acceptance criteria
- Current progress and next steps
- Key files and referenced docs
- Blockers and gotchas

## Output

Saves to `.claude/docs/handoff/YYYY-MM-DD-<count>-<slug>.md`

## Implementation

Calls `handoff/SKILL.md` for execution logic.
