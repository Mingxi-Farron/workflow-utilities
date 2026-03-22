---
name: plan
description: "Create a task plan using Opus reasoning model with iterative user feedback. Triggers: make a plan, create plan, 制定计划, plan task"
argument-hint: "<task-name> | --progress [file]"
---

# Plan Skill

## Natural Language Triggers

- `/plan <task-name>` — create a new plan
- `/plan --progress` — update progress on the latest plan
- `/plan --progress <file>` — update progress on a specific plan file
- "make a plan" / "create a plan" / "plan this task"
- "制定计划" / "做个计划"
- "更新进度" / "plan progress" / "mark progress"

---

## Argument Router

**Check `$ARGUMENTS` before doing anything else:**

- If `$ARGUMENTS` starts with `--progress` (case-insensitive) → jump to **[Progress Subskill]** below. Stop. Do not run Steps 1–7.
- Otherwise → continue to Step 1 (create workflow).

---

# Create Workflow

**When triggered to CREATE, execute Steps 1–7 below.**

---

## Step 1 — Resolve Task Name

- If `$ARGUMENTS` is non-empty, use it as the task name.
- If empty, ask the user: "What is the task name for this plan?"

---

## Step 2 — Collect Parameters

Ask the user to provide (or extract from conversation context):

```
Please provide the following (skip any that don't apply):

1. **Goal** — What problem are we solving? What does success look like?
2. **Constraints / Environment** — Technical limits, platform, framework versions, forbidden approaches
3. **Input** — What is given? (files, data, existing code, APIs)
4. **Output** — What should be produced? (files, features, behaviors)
```

If the user has already described these in the conversation, extract them automatically and confirm before proceeding:

```
Extracted parameters:
- Goal: ...
- Constraints: ...
- Input: ...
- Output: ...

Proceed with these? (or edit any field)
```

---

## Step 3 — Generate Plan with Opus

Use the Agent tool with `subagent_type="Plan"` and include all parameters from Step 2.

**Agent prompt template:**

```
You are a senior software architect. Create a detailed, actionable implementation plan.

## Task: <task-name>

## Goal
<goal from Step 2>

## Constraints / Environment
<constraints from Step 2>

## Input
<input from Step 2>

## Output
<output from Step 2>

## Project Context
<Read from CLAUDE.md or project README — summarize the tech stack, key paths, and conventions>

## Prioritization Principle
When the task involves multiple features or phases, structure steps by priority:
- **P0 (MVP):** Minimum to make it functional and testable — the task is "done enough" at this point
- **P1:** Core features needed to fully meet acceptance criteria
- **P2:** Polish, edge cases, nice-to-have improvements

Skip this structure for single-concern tasks (bug fixes, refactors, research). Use judgment.

## Deliverable
Produce a structured plan with:
1. **Objective** — 1-2 sentence restatement of goal
2. **Acceptance Criteria** — Concrete, testable checklist (tag each with P0/P1/P2 if prioritized)
3. **Approach** — High-level strategy and key decisions
4. **Implementation Steps** — Ordered, dependency-aware step list. Each step: what to do, which files, expected result. Group under P0/P1/P2 headings if applicable.
5. **Key Files** — Files to read, edit, or create
6. **Risks & Mitigations** — What could go wrong and how to handle it
7. **Out of Scope** — Explicitly what this plan does NOT cover
```

Show the generated plan to the user.

---

## Step 4 — Iterate Until Approved

After showing the plan:

```
Plan ready. Feedback? (or type "approved" / "确认" to save)
```

**Feedback loop:**
- User provides feedback → re-run Step 3 Agent with feedback appended to prompt
- Repeat until user says: `approved`, `ok`, `确认`, `好的`, `save`, or `写入`
- Maximum 5 iterations — if exceeded, ask user to confirm saving current version

---

## Step 5 — Determine File Path

**Get today's date:**
```
date "+%Y-%m-%d"
```

**Determine count:**
1. List files in `.claude/docs/plan/` (create dir if it doesn't exist)
2. Filter files matching today's date prefix `YYYY-MM-DD-`
3. Extract count integers from matching filenames (`YYYY-MM-DD-<count>-<slug>.md`)
4. `count = max_existing_count + 1` (start from 1 if none exist today)

**Build slug:**
- Convert task name to kebab-case (lowercase, spaces → hyphens, strip special chars)
- Example: "audio controller timer" → `audio-controller-timer`

**Final path:**
```
.claude/docs/plan/YYYY-MM-DD-<count>-<slug>.md
```

Example: `.claude/docs/plan/2026-03-16-1-audio-controller-timer.md`

**Rules:**
- ALWAYS create a new file. NEVER overwrite an existing plan file.
- Multiple plans on the same day get incrementing count numbers.

---

## Step 6 — Write the File

Use this template:

```markdown
# Plan: <Task Name>
**Date:** YYYY-MM-DD
**Status:** approved

## Objective
1-2 sentences. What problem does this solve?

## Acceptance Criteria
- [ ] Concrete, testable criterion
- [ ] Another criterion

## Approach
High-level strategy. Key architectural decisions. Why this approach over alternatives.

## Implementation Steps

### Step 1: <Name>
- **What:** Description of action
- **Files:** `path/to/file.ext`, `path/to/other.ext`
- **Result:** What the code/system looks like after this step

### Step 2: <Name>
...

## Key Files
- `path/to/file.ext` — brief note on relevance

## Risks & Mitigations
| Risk | Mitigation |
|------|-----------|
| Description of risk | How to handle it |

## Out of Scope
- Explicitly what this plan does NOT cover
- Helps future sessions avoid scope creep
```

**Writing rules:**
- Steps must be ordered by dependency (earlier steps unblock later ones)
- Each step references specific file paths, not vague descriptions
- Acceptance criteria must be testable — avoid "works correctly" style
- Keep Approach section focused on decisions, not repetition of steps
- Omit any section that would be empty

---

## Step 7 — Confirm

Output:

```
Plan saved: .claude/docs/plan/<filename>.md
Steps: <N> | Acceptance criteria: <N>
```

---

# Progress Subskill

**Trigger:** `/plan --progress`, `/plan --progress <file>`, "更新进度", "plan progress", "mark progress"

---

## Progress Step 1 — Resolve Plan File

1. If `$ARGUMENTS` contains a file path after `--progress` → use that path directly.
2. Otherwise, **find the latest plan file:**
   - List files in `.claude/docs/plan/`
   - If empty, output "No plan files found." and stop.
   - Sort alphabetically (lexicographic = chronological). The last entry is most recent.
3. **Read the plan file** using the Read tool.
4. Show to user:
   ```
   Updating progress on: .claude/docs/plan/<filename>.md
   ```

---

## Progress Step 2 — Analyze Current State

Examine the conversation context and the plan file to determine the status of each step:

**For each Implementation Step, classify as one of:**

| Status Tag | Meaning | When to apply |
|---|---|---|
| `[DONE]` | Fully completed | Code written + compiled + tested + **user confirmed working** |
| `[IN PROGRESS]` | Currently being worked on | Code partially written or under active development |
| `[NEXT]` | Immediate next step | First unblocked pending step after all `[DONE]` / `[IN PROGRESS]` items |
| `[PENDING]` | Not started | Waiting for earlier steps to complete |
| `[BLOCKED]` | Cannot proceed | Dependency or blocker prevents starting |

**For each Acceptance Criterion:**

| Marker | Meaning | When to apply |
|---|---|---|
| `[x]` | Met | Corresponding steps are `[DONE]` + user confirmed |
| `[ ]` | Not yet met | Still pending |

**CRITICAL CONSTRAINT:** Never mark a step as `[DONE]` or a criterion as `[x]` unless:
1. The implementation code has been written
2. The code compiles/builds successfully
3. The feature has been tested (runtime verification or user-reported test)
4. The user has explicitly confirmed it works ("works", "confirmed", "tested", "ok", "通过", "确认")

If in doubt, use `[IN PROGRESS]` rather than `[DONE]`.

---

## Progress Step 3 — Draft Progress Update

Show the user a summary before writing:

```
Progress update for: <Plan Title>

Steps:
  [DONE]        Step 1: <name>
  [DONE]        Step 2: <name>
  [IN PROGRESS] Step 3: <name>
  [NEXT]        Step 4: <name>
  [PENDING]     Step 5: <name>

Acceptance Criteria: <N>/<Total> met

Proceed with update? (yes/no)
```

Wait for user confirmation before writing.

---

## Progress Step 4 — Update the Plan File

Apply changes to the **same plan file** (in-place update, not a new file):

1. **Update `**Status:**`** line:
   - All steps DONE + all criteria `[x]` → `**Status:** completed`
   - All steps DONE but unmet criteria remain → `**Status:** steps-done` (see **Unmet Criteria Gate** below)
   - Any step IN PROGRESS → `**Status:** in-progress`
   - All steps PENDING → `**Status:** approved` (unchanged)

   **Unmet Criteria Gate:** When all steps are DONE but some criteria are still `[ ]`:
   1. List the unmet criteria to the user, grouped by priority (P0/P1/P2)
   2. For each unmet criterion, ask the user to choose one of:
      - **"done"** — actually met, mark `[x]`
      - **"skip"** — intentionally skipped, mark `[~] (skipped)`
      - **"defer"** — port to a new plan, mark `[→] (deferred)`
      - **"ignore"** — not applicable, mark `[–] (ignored)`
   3. Only after ALL unmet criteria have been resolved by the user, set `**Status:** completed`
   4. If the user declines to resolve now, keep `**Status:** steps-done` — do NOT set completed

2. **Update each `### Step N:` heading** — prepend status tag:
   ```markdown
   ### Step 1: Add GetWindowStates [DONE]
   ### Step 2: DrawPanel returns bool [IN PROGRESS]
   ### Step 3: Add Load/Save methods [NEXT]
   ### Step 4: Update preservation list [PENDING]
   ```

3. **Update Acceptance Criteria** checkboxes:
   ```markdown
   - [x] (P0) toggle auto-saves to local.json
   - [ ] (P0) game startup restores state
   ```

4. **Append a `## Progress Log` section** at the bottom (create if absent, append if exists):
   ```markdown
   ## Progress Log

   ### YYYY-MM-DD
   - Step 1 [DONE]: <1-line summary of what was done>
   - Step 2 [IN PROGRESS]: <what's been done so far, what remains>
   - Blockers: <any blockers, or "none">
   - Criteria resolved: (P2) "criterion text" → skipped / deferred / ignored
   ```
   Each update appends a new dated entry. Never overwrite previous log entries.
   Include criterion disposition lines only when criteria were resolved in this update.

---

## Progress Step 5 — Confirm

Output:

```
Progress updated: .claude/docs/plan/<filename>.md
Status: <status> | Steps: <done>/<total> done | Criteria: <met>/<total> met
```
