---
name: git-guard
version: "2.0.0"
description: "Prevent destructive git operations via PreToolUse hook. Blocks reset --hard, clean -f, checkout --, restore ., and filter-repo --force."
user-invocable: false
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# Git Guard - Destructive Git Operation Protection

Blocks destructive git commands before they execute via a PreToolUse hook script.

## What It Blocks

| Command | Why | Suggested Alternative |
|---------|-----|----------------------|
| `git filter-repo --force` | Rewrites history + purges reflog | `git stash` → `git filter-repo` (no --force) → `git stash pop` |
| `git reset --hard` | Discards all uncommitted changes permanently | `git stash` → `git reset --hard` → `git stash pop` |
| `git clean -f` | Deletes untracked files permanently | `git stash` → `git clean` → `git stash pop` |
| `git checkout -- .` | Overwrites all working tree files | `git stash` → run command → `git stash pop` |
| `git restore .` | Overwrites all working tree files | `git stash` → run command → `git stash pop` |

## How It Works

The hook script `guard-git.sh` runs as a **PreToolUse** hook on every `Bash` tool call. It reads the command from stdin and pattern-matches against known destructive git commands. If matched, it prints a `BLOCKED:` message with a safe alternative and exits 1 to prevent execution.

Non-matching commands pass through (exit 0).

## Installation

### Option 1: Copy the hook script

Copy `guard-git.sh` to your project's `.claude/hooks/` directory:

```bash
cp workflow-utilities/git-guard/guard-git.sh .claude/hooks/guard-git.sh
```

### Option 2: Reference from plugin path

Point directly to the plugin's script (if installed as a plugin):

```json
"command": "bash workflow-utilities/git-guard/guard-git.sh"
```

### Register in settings.json

Add to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/guard-git.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## Design Notes

- **No overrides via flags** — the hook always blocks. The user must explicitly run the safe alternative.
- **Lightweight** — pure bash, no dependencies, runs in < 100ms.
- **Composable** — works alongside other PreToolUse hooks. Each hook is independent.
- The `/commit` command workflow handles `git commit` and `git push` through a separate confirmation flow, not through this hook.
