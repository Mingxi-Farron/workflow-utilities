---
name: optimization-ticket
version: "2.0.0"
description: Record, assign, and track optimization tasks throughout their lifecycle. Supports TASK/MOD/HOTFIX types with lock protocol for concurrent assignment prevention.
user-invocable: true
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# Optimization Ticket - Task Management System

Record, assign, and track optimization tasks throughout their lifecycle.

## Tool Path

```
TOOL = _system/tools/ticket_manager.py
INVOKE = PYTHONUTF8=1 python {TOOL}
```

## Trigger Conditions

- User natural language task operations
- User calls `/ticket` command
- Agent discovers optimization needs (auto-create)
- Agent starts/completes tasks (auto-update)

## Natural Language Understanding

### List Tasks (zh)
- "有什么任务"
- "任务列表"
- "待办事项"
- "还有哪些要做"
- "看看任务"

### List Tasks (en)
- "what tasks"
- "task list"
- "todo list"
- "pending tasks"
- "show tasks"

### Show Task (zh)
- "看看 {id}"
- "{id} 是什么"
- "任务详情"
- "{id} 的内容"

### Show Task (en)
- "show {id}"
- "what is {id}"
- "task details"
- "describe {id}"

### Create Task (zh)
- "创建任务"
- "新建任务"
- "添加一个任务"
- "记录一个问题"

### Create Task (en)
- "create task"
- "new task"
- "add task"
- "log an issue"

### Complete Task (zh)
- "{id} 完成了"
- "{id} 做完了"
- "关闭 {id}"
- "搞定 {id}"

### Complete Task (en)
- "{id} is done"
- "finished {id}"
- "close {id}"
- "complete {id}"

### Assign Task (zh)
- "开始做 {id}"
- "我来处理 {id}"
- "接手 {id}"

### Assign Task (en)
- "start {id}"
- "work on {id}"
- "take {id}"

### Validate Tickets (zh)
- "检查任务完整性"
- "验证ticket"
- "ticket检查"

### Validate Tickets (en)
- "validate tickets"
- "check ticket integrity"

## Task Schema

```yaml
id: "TASK-XXX / MOD-XXX / HOTFIX-XXX"
title: "Task title"
problem: "Problem description"
scope: "Implementation scope"
status: "pending | in_progress | completed | on_hold | observing"
dependencies: ["Other task IDs"]
assignee: "Agent ID"
created: "Creation timestamp"
updated: "Last update timestamp"
```

## Task Types

| Type | Prefix | Description |
|------|--------|-------------|
| TASK | TASK- | Small optimization task |
| MOD | MOD- | Large module development |
| HOTFIX | HOTFIX- | Urgent fix |

## Status Definitions

| Status | Icon | Description |
|--------|------|-------------|
| pending | ... | Waiting, can be assigned |
| in_progress | (locked) | Being worked on (locked) |
| completed | (done) | Finished |
| on_hold | (paused) | Suspended |
| observing | (watching) | Under observation |

## Operations

All operations dispatch to `ticket_manager.py`. The agent parses user intent via NLU, then invokes the tool.

### LIST
```
PYTHONUTF8=1 python _system/tools/ticket_manager.py list [--status pending|completed|all] [--type TASK|MOD|HOTFIX] [--all]
```

### SHOW
```
PYTHONUTF8=1 python _system/tools/ticket_manager.py show {id}
```

### CREATE
```
PYTHONUTF8=1 python _system/tools/ticket_manager.py create --type {TASK|MOD|HOTFIX} --title "{title}" --priority {P0|P1|P2|P3} [--problem "{problem}"] [--scope "{scope}"] [--deps "ID1,ID2"]
```

### ASSIGN
```
PYTHONUTF8=1 python _system/tools/ticket_manager.py assign {id} [--assignee {name}]
```

### COMPLETE
```
PYTHONUTF8=1 python _system/tools/ticket_manager.py close {id} [--status completed]
```

### VALIDATE
```
PYTHONUTF8=1 python _system/tools/ticket_manager.py validate
```

## Lock Protocol

Lock acquisition, timeout detection, and release are enforced internally by `ticket_manager.py`. The agent does not manage lock state directly.

### Lock Info Format
```
**Status**: in_progress (locked)
**Lock**: Agent-{ID} | {time} | Est. {duration}
```

### Timeout
- Duration: 4 hours
- Action: Considered expired, takeover allowed
- Takeover format: `Agent-{new} | {time} | Takeover from Agent-{old}`

## Data Layout

```
tickets/
  INDEX.md          # Summary table (lightweight, LIST reads only this)
  active/           # pending, in_progress, on_hold, partial, observing
    TASK-004.md
    MOD-013.md
  archive/          # completed, done, implemented, superseded, absorbed
    TASK-001.md
```

## Message Templates

Uses `messages/{language}.json` keys:
- `ticket.list_header`
- `ticket.empty`
- `ticket.created`
- `ticket.completed`
- `ticket.locked`
- `ticket.not_found`
- `ticket.already_locked`
- `ticket.dependency_not_met`
