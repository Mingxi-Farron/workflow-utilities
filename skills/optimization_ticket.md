# Optimization Ticket - Task Management System

Record, assign, and track optimization tasks throughout their lifecycle.

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

### LIST
```
1. Read OPTIMIZATION_TICKETS.md
2. Filter tasks with status=pending
3. Format and output
```

### SHOW
```
1. Find task by ID
2. Display full details
```

### CREATE
```
1. Determine task type (TASK/MOD/HOTFIX)
2. Assign unique ID
3. Fill in problem and scope
4. Set status=pending
5. Write to ticket file
```

### ASSIGN
```
1. Check if status is pending
2. Check if dependencies are met
3. Execute lock protocol
4. Update assignee and status=in_progress
```

### COMPLETE
```
1. Update status=completed
2. Release lock
3. Record completion time
4. Update downstream dependencies
```

## Lock Protocol

### Acquire Lock
```
1. Check if task status is pending
2. If pending, update to in_progress with lock info
3. If already locked, skip task
```

### Lock Info Format
```
**Status**: in_progress (locked)
**Lock**: Agent-{ID} | {time} | Est. {duration}
```

### Release Lock
```
1. Update status to completed
2. Clear lock info
```

### Timeout
- Duration: 4 hours
- Action: Considered expired, takeover allowed
- Takeover format: `Agent-{new} | {time} | Takeover from Agent-{old}`

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
