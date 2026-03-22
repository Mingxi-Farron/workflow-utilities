---
description: "Create a task plan with iterative feedback, or update progress"
argument-hint: "<task-name> | --progress [file]"
---

# /plan - Task Planning Command

Create structured implementation plans using Opus reasoning, or update progress on existing plans.

## Usage

```
/plan <task-name>          # Create a new plan
/plan --progress           # Update progress on latest plan
/plan --progress <file>    # Update progress on specific plan file
```

## Workflow

1. Collect goal, constraints, input, output
2. Generate plan via Opus Plan agent (P0/P1/P2 prioritization)
3. Iterate with user feedback (up to 5 rounds)
4. Save to `.claude/docs/plan/YYYY-MM-DD-<count>-<slug>.md`

## Progress Tracking

Status tags per step: `[DONE]`, `[IN PROGRESS]`, `[NEXT]`, `[PENDING]`, `[BLOCKED]`

Strict completion rules — `[DONE]` requires code written + built + tested + user confirmed.

## Implementation

Calls `plan/SKILL.md` for execution logic.
