---
name: handoff
description: "Create a concise handoff file for unfinished tasks. Triggers: 交接, handoff, create handoff"
argument-hint: "<task-name> | --read"
---

# Handoff Skill

## Natural Language Triggers

- `/handoff <task-name>` — create a new handoff file
- `/handoff --read` — read the latest handoff file
- "create handoff" / "handoff"
- "交接" / "交接文档"
- "读取交接" / "查看最新交接" / "read latest handoff"

---

## Argument Router

**Check `$ARGUMENTS` before doing anything else:**

- If `$ARGUMENTS` == `--read` (case-insensitive) → jump to **[Read Subskill]** below. Stop. Do not run Steps 1–6.
- Otherwise → continue to Step 1 (create workflow).

---

# Create Workflow

**When triggered to CREATE, execute Steps 1–6 below.**

---

## Step 1 — Resolve Task Name

- If `$ARGUMENTS` is non-empty, use it as the task name.
- If empty, ask the user: "What is the task name for this handoff?"

---

## Step 2 — Determine File Path

**Get today's date:**
```
date "+%Y-%m-%d"
```

**Determine count:**
1. List files in `.claude/docs/handoff/` (create the dir if it doesn't exist)
2. Filter files matching prefix `YYYY-MM-DD-` (today's date)
3. Extract the count integer from each matching filename (`YYYY-MM-DD-<count>-<slug>.md`)
4. `count = max_existing_count + 1` (start from 1 if none exist)

**Build slug:**
- Convert task name to kebab-case (lowercase, spaces → hyphens, strip special chars)
- Example: "user config cleanup" → `user-config-cleanup`

**Final path:**
```
.claude/docs/handoff/YYYY-MM-DD-<count>-<slug>.md
```

Example: `.claude/docs/handoff/2026-03-16-1-user-config-cleanup.md`

**Rules:**
- ALWAYS create a new file. NEVER update an existing handoff file.
- Multiple handoffs on the same day get incrementing count numbers.

---

## Step 3 — Analyze Conversation Context

Extract from the current conversation:

| Field | What to look for |
|---|---|
| **Goal** | What was the user trying to accomplish? |
| **Status** | Is it `in-progress`, `blocked`, or `ready-to-test`? |
| **Type** | `impl` if this session is implementing a plan (env `CLAUDE_SESSION_TYPE=impl`), otherwise omit |
| **Acceptance Criteria** | What does "done" look like? |
| **Progress** | What was completed? (tool calls, edits, confirmed results) |
| **Next Steps** | What remains? (ordered by dependency) |
| **Key Files** | Files read, edited, or created |
| **Docs Referenced** | Any `.claude/docs/` files consulted |
| **Blockers / Notes** | Errors, constraints, unresolved questions |

---

## Step 4 — Draft and Confirm

Show the user a one-line summary:

```
Handoff: "<Task Name>" | Status: <status> | File: .claude/docs/handoff/<filename>.md
Next steps: <count> items | Key files: <count>
```

Then write the file immediately. (No need to wait for explicit approval unless the status or task name is ambiguous.)

---

## Step 5 — Write the File

Use this template. **Skip any section that has no content — do not leave empty sections.**

```markdown
# Handoff: <Task Name>
**Status:** in-progress | blocked | ready-to-test
**Type:** impl  ← ONLY include this line if CLAUDE_SESSION_TYPE=impl (plan implementation session)
**Date:** YYYY-MM-DD

## Goal
1-2 sentences max. What problem is being solved?

## Acceptance Criteria
- [ ] Concrete, testable criterion
- [ ] Another criterion

## References
- `.claude/docs/some-doc.md` — brief description of what it covers
- `path/to/relevant-file.ext` — brief note

## Current Progress
- Brief bullet of what's done
- Another completed item

## Next Steps
1. First thing to do (most immediate)
2. Second thing
3. Third thing

## Key Files
- `path/to/file.ext` — brief note on relevance

## Notes
Gotchas, active blockers, or constraints worth knowing.
```

**Writing rules:**
- Bullets over paragraphs everywhere
- Reference doc/file PATHS — do not inline the research content
- Keep each bullet to 1 line where possible
- Goal section: 1-2 sentences max, no more
- Notes section: only include if there are genuine gotchas or blockers
- Omit any section that would be empty

---

## Step 6 — Confirm

Output:

```
Handoff created: .claude/docs/handoff/<filename>.md
Status: <status>
Next steps: <N> items
```

---

# Read Subskill

**Trigger:** `/handoff --read` or "读取交接" / "查看最新交接文件"

## Steps

1. **List files** in `.claude/docs/handoff/` — if the directory is missing, output "No handoff files found." and stop.
2. **Find the latest file:**
   - Sort filenames alphabetically (they are `YYYY-MM-DD-<count>-<slug>.md` format, so lexicographic order = chronological order).
   - The last entry is the most recent.
3. **Read the file** using the Read tool.
4. **Output:**
   ```
   Latest handoff: .claude/docs/handoff/<filename>.md
   ---
   <full file contents>
   ```
