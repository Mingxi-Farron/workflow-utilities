---
description: "Trigger the git commit confirmation flow"
argument-hint: ""
---

# /commit - Git Commit Command

Trigger the git commit confirmation flow.

## Usage

```
/commit                    # Start commit confirmation flow
```

## Flow

1. Show pending changes (staged and unstaged)
2. Ask user for confirmation
3. If confirmed, execute git commit
4. If rejected, cancel operation

## Natural Language Alternatives

Instead of the command, you can say:
- "Commit these changes"
- "Yes, commit"
- "Go ahead and commit"

Or to reject:
- "Don't commit"
- "Cancel"
- "Not yet"

## Implementation

Calls `git-guard/SKILL.md` confirmation flow.
