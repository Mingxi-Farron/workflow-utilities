---
description: "Execute tasks with structured workflow (review -> test -> implement -> verify)"
argument-hint: "[execute|review|test|close] {task-id}"
---

# /task - Structured Task Execution Command

Execute tasks using a structured workflow with subagent orchestration: Review -> Test Design -> Implementation -> Verification.

## Usage

```
/task {id}                 # Execute full workflow for task
/task execute {id}         # Execute full workflow for task
/task review {id}          # Review only (Phase 2)
/task test {id}            # Design tests only (Phase 3)
/task close {id}           # Close task (requires prior approval)
```

## Workflow Phases

| Phase | Agent | Description |
|-------|-------|-------------|
| 1. Identification | - | Read ticket, parse requirements |
| 2. Review | Plan | Analyze code, identify risks, suggest order |
| 3. Test Design | Plan | Design unit/integration/boundary tests |
| 4. Implementation | Code | Write code, modify files |
| 5. Verification | - | Present results, wait for user test |
| 6. Close | - | Update ticket (requires user approval) |

## Examples

### Full Workflow
```
/task TASK-015
```
Executes all phases: review -> test design -> implementation -> verification -> close (with approval).

### Review Only
```
/task review TASK-015
```
Only performs Phase 2: analyzes design, identifies risks, suggests implementation order.

### Test Design Only
```
/task test TASK-015
```
Only performs Phase 3: designs unit tests, integration tests, boundary tests.

### Close Task
```
/task close TASK-015
```
Marks task as complete. Only works after user has approved verification.

## Natural Language Alternatives

Instead of commands, you can say:

| Natural Language | Equivalent Command |
|------------------|-------------------|
| "Execute TASK-015" | `/task TASK-015` |
| "Do TASK-015" | `/task TASK-015` |
| "Review TASK-015" | `/task review TASK-015` |
| "Write tests for TASK-015" | `/task test TASK-015` |
| "Close TASK-015" | `/task close TASK-015` |

## Important Notes

1. **User Approval Required**: Task cannot be closed without explicit user approval (e.g., "confirmed", "LGTM", "approved")

2. **Dependencies**: Review must complete before implementation; implementation must complete before verification

3. **Parallel Execution**: Multiple independent tasks can be reviewed/tested in parallel, but implementation follows review

## Implementation

Calls `task-execution/SKILL.md` for execution logic.
