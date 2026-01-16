---
name: git-guard
version: "1.0.0"
description: Prevent unauthorized git operations and require user confirmation for commits and pushes. Intercepts git commit/push commands via PreToolUse hook.
user-invocable: true
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/git_guard.sh"
---

# Git Guard - Git Operation Protection

Prevent unauthorized git operations and require user confirmation for commits and pushes.

## Trigger Conditions

- Hook intercepts git commit/push commands
- User natural language confirmation/rejection
- User calls `/commit` command

## Natural Language Understanding

### Confirm (zh)
- "提交"
- "commit"
- "是"
- "确认"
- "好的"
- "可以"

### Confirm (en)
- "commit"
- "yes"
- "confirm"
- "ok"
- "go ahead"

### Reject (zh)
- "不要"
- "取消"
- "算了"
- "不提交"

### Reject (en)
- "no"
- "cancel"
- "don't"
- "abort"

## Blocked Actions

| Action | Behavior | Override |
|--------|----------|----------|
| git commit | Require confirmation | User confirms |
| git push | Require confirmation | User confirms |
| git push --force | Blocked | User explicitly requests |
| git reset --hard | Blocked | User explicitly requests |
| git rebase -i | Blocked | Not supported |

## Execution Logic

```
1. Receive Hook intercept signal
2. Display pending changes to user
3. Ask for confirmation
4. Wait for user natural language response
5. If confirmed -> Execute git command
6. If rejected -> Cancel operation
```

## Commit Format

```
[Module] Change description

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Message Templates

Uses `messages/{language}.json` keys:
- `git_guard.blocked`
- `git_guard.confirm_prompt`
- `git_guard.confirmed`
- `git_guard.rejected`
- `git_guard.force_blocked`
