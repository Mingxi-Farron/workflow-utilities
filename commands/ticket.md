---
description: "Manage optimization tickets and tasks"
argument-hint: "[list|show {id}|create|close {id}|validate]"
---

# /ticket - Task Management Command

Manage optimization tickets: create, list, assign, and complete tasks.

## Usage

```
/ticket                    # List pending tasks
/ticket list               # List pending tasks (filterable)
/ticket list --all         # List all tasks
/ticket list --type MOD    # List only MOD tickets
/ticket show {id}          # Show task details
/ticket create             # Create new task interactively
/ticket close {id}         # Mark task as completed
/ticket validate           # Check ticket integrity
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
- "Check ticket integrity" -> `/ticket validate`

## Data Layout

```
tickets/
  INDEX.md          # Summary table (read by list)
  active/           # Individual ticket files (pending, in_progress, ...)
  archive/          # Completed/closed tickets
```

## Implementation

Calls `optimization-ticket/SKILL.md` which dispatches to
`python _system/tools/ticket_manager.py <subcommand>`.
