#!/bin/bash
# Guard against destructive git commands
# Claude Code PreToolUse hook — exits 1 to block the tool call
#
# Usage in .claude/settings.json:
#   "PreToolUse": [{
#     "matcher": "Bash",
#     "hooks": [{
#       "type": "command",
#       "command": "bash .claude/hooks/guard-git.sh",
#       "timeout": 5
#     }]
#   }]

INPUT=$(cat)

# filter-repo --force: rewrites history + git reset --hard, purges reflog
if echo "$INPUT" | grep -qE "filter-repo.*--force|--force.*filter-repo"; then
    echo "BLOCKED: git filter-repo --force overwrites working tree and purges reflog."
    echo "Required: git stash → git filter-repo (no --force) → git stash pop"
    exit 1
fi

# reset --hard: discards all uncommitted changes
if echo "$INPUT" | grep -qE "git[[:space:]]+reset[[:space:]]+--hard"; then
    echo "BLOCKED: git reset --hard discards all uncommitted changes permanently."
    echo "Required: git stash → git reset --hard → git stash pop"
    exit 1
fi

# clean -f: deletes untracked files permanently
if echo "$INPUT" | grep -qE "git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f"; then
    echo "BLOCKED: git clean -f permanently deletes untracked files."
    echo "Required: git stash → git clean → git stash pop"
    exit 1
fi

# checkout -- . or restore .: overwrites all working tree files
if echo "$INPUT" | grep -qE "git[[:space:]]+(checkout[[:space:]]+--[[:space:]]+\.|restore[[:space:]]+\.)"; then
    echo "BLOCKED: git checkout -- . / git restore . discards all working tree changes."
    echo "Required: git stash → run command → git stash pop"
    exit 1
fi

exit 0
