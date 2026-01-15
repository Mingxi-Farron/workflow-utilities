---
description: "Manage optimization tickets and tasks"
argument-hint: "[list|show {id}|create|close {id}]"
---

# /ticket - Task Management Command

Manage optimization tickets: create, list, assign, and complete tasks.

## Usage

```
/ticket                    # List pending tasks
/ticket list               # List pending tasks
/ticket show {id}          # Show task details
/ticket create             # Create new task interactively
/ticket close {id}         # Mark task as completed
```

## Task Types

| Type | Prefix | Description |
|------|--------|-------------|
| TASK | TASK- | Small optimization task |
| MOD | MOD- | Large module development |
| HOTFIX | HOTFIX- | Urgent fix |

## Task Status

| Status | Icon | Description |
|--------|------|-------------|
| pending | ... | Waiting to be assigned |
| in_progress | (locked) | Being worked on |
| completed | (done) | Finished |
| on_hold | (paused) | Temporarily suspended |
| observing | (watching) | Under observation |

## Natural Language Alternatives

Instead of commands, you can say:
- "What tasks are there?" -> `/ticket list`
- "Show me TASK-015" -> `/ticket show TASK-015`
- "Create a task about..." -> `/ticket create`
- "TASK-015 is done" -> `/ticket close TASK-015`

## Implementation

Calls `skills/optimization_ticket.md` for execution logic.
