---
name: task-execution
version: "1.0.0"
description: Execute tasks using a structured workflow with subagent orchestration - Review, Test Design, Implementation, Verification phases.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
---

# Task Execution - Structured Task Development Workflow

Execute tasks using a structured workflow with subagent orchestration: Review -> Test Design -> Implementation -> Verification.

## Trigger Conditions

- User calls `/task` command
- User natural language task execution requests
- Agent receives task assignment from ticket system

## Natural Language Understanding

### Execute Task (zh)
- "执行任务 {id}"
- "做 {id}"
- "开始 {id}"
- "实现 {id}"
- "处理 {id}"

### Execute Task (en)
- "execute task {id}"
- "do {id}"
- "start {id}"
- "implement {id}"
- "work on {id}"

### Review Only (zh)
- "审核 {id}"
- "检查 {id} 的设计"
- "分析 {id}"

### Review Only (en)
- "review {id}"
- "check design for {id}"
- "analyze {id}"

### Test Design Only (zh)
- "为 {id} 写测试"
- "设计 {id} 的测试"
- "{id} 的测试步骤"

### Test Design Only (en)
- "write tests for {id}"
- "design tests for {id}"
- "test steps for {id}"

### Close Task (zh)
- "关闭 {id}"
- "{id} 验证通过"
- "完成 {id}"

### Close Task (en)
- "close {id}"
- "{id} verified"
- "complete {id}"

## Workflow Phases

```
Phase 1: Task Identification
    |
    v
Phase 2: Review (Plan Agent)
    |
    v
Phase 3: Test Design (Plan Agent)
    |
    v
Phase 3.5: Test File Creation (Code Agent) ← MANDATORY DEFAULT
    |
    v
Phase 4: Implementation (Code Agent)
    |
    v
Phase 5: User Verification (run tests, confirm pass)
    |
    v
Phase 6: Close Ticket (requires user approval)
```

> **MANDATORY TEST RULE**: Phase 3.5 is NOT optional. Acceptance criteria are interpreted
> by the LLM from ticket text — without external enforcement, test files are the only
> executable verification. Test files MUST be created before implementation begins.

## Phase Details

### Phase 1: Task Identification

```
1. Invoke `PYTHONUTF8=1 python _system/tools/ticket_manager.py show {id}` to retrieve task details
2. Parse the output for task metadata
3. Parse requirements and acceptance criteria
4. Optionally mark status: Open -> In Progress
5. Output task summary for confirmation
```

**Output:**
- Task ID and title
- Problem description
- Implementation scope
- Dependencies (if any)
- Acceptance criteria

### Phase 2: Review (Plan Agent)

**Agent Type:** Plan (read-only)

**Purpose:**
- Analyze existing code structure
- Identify files requiring modification
- Discover risks (thread safety, memory, compatibility)
- Suggest implementation order
- Check prerequisites

**Prompt Template:**

```markdown
## Task: Review {TASK-ID} Implementation Plan

### Background
{task description from ticket}

### Items to Review
1. {requirement 1}
2. {requirement 2}
3. {requirement 3}

### Related Files
- `{file1}` - {purpose}
- `{file2}` - {purpose}

### Please Complete
1. Check if existing code structure supports requirements
2. Identify files and functions requiring modification
3. Discover potential risks (thread safety, memory management, compatibility)
4. Suggest implementation order
5. Identify missing dependencies or prerequisites

### Output Format
- Risk list (High/Medium/Low)
- Suggested implementation steps
- Edge cases to handle
```

**Output Expected:**
- Risk assessment
- Implementation plan
- File modification list
- Edge cases

### Phase 3: Test Design (Plan Agent)

**Agent Type:** Plan (read-only)

**Purpose:**
- Design unit tests
- Design integration tests
- Design boundary tests
- Create test matrix

**Prompt Template:**

```markdown
## Task: Design Tests for {feature name}

### Feature Description
{what the feature does, inputs and outputs}

### Related Code
- `{implementation file}`
- `{interface file}`

### Please Design Tests

#### 1. Unit Tests
- Test individual functions/methods
- Cover normal and boundary inputs

#### 2. Integration Tests
- Test interaction with other modules
- Verify data flow correctness

#### 3. Boundary Tests
- Null/empty handling
- Maximum/minimum values
- Concurrent access (if applicable)
- Error recovery

### Output Format
Each test item should include:
- Test name
- Preconditions
- Execution steps
- Expected results
- Verification method
```

**Output Expected:**
- Test case list with target file paths
- Preconditions
- Step-by-step verification
- Expected outcomes
- Target test file path (e.g. `tests/test_{feature}.py`)

---

### Phase 3.5: Test File Creation (Code Agent) — MANDATORY

**Agent Type:** Code (read-write)

**Mandatory Rule:** This phase is ALWAYS executed. It cannot be skipped.
- Acceptance criteria come from LLM interpretation of ticket text — no external enforcement exists.
- Test files are the only executable verification of correctness.
- If the task has no explicit test requirement, the LLM MUST still write tests covering the acceptance criteria it identified.

**Purpose:**
- Write actual test files based on Phase 3 design
- Tests must be runnable immediately (no stub placeholders)
- Tests should FAIL before implementation (TDD), PASS after implementation

**Test File Naming:**
| Language | Convention | Example |
|----------|-----------|---------|
| Python | `tests/test_{module}.py` | `tests/test_risk_checker.py` |
| TypeScript/JS | `{module}.test.ts` | `risk_checker.test.ts` |
| Go | `{module}_test.go` | `risk_checker_test.go` |

**Scope:**
- Unit tests: mandatory
- Integration/e2e tests: mandatory if task touches module boundaries or external interfaces
- Boundary tests: mandatory

**Prompt Template:**

```markdown
## Task: Write Test Files for {feature name}

### Test Design (from Phase 3)
{paste Phase 3 output}

### Requirements
- Write runnable test files, not pseudocode or stubs
- Each test must have a clear assertion
- Tests must FAIL before implementation exists
- Cover: unit, integration (if applicable), boundary cases

### Files to Create
- `{test file path}` — {what it covers}

### Do NOT implement the feature itself — tests only.
```

**Output Expected:**
- Actual test files written to disk
- List of test files created
- Confirmation that tests are runnable (imports resolve, syntax valid)

---

### Phase 4: Implementation (Code Agent)

**Agent Type:** Code (read-write)

**Purpose:**
- Write actual code
- Create/modify files
- Execute git operations (if applicable)

**Prompt Template:**

```markdown
## Task: Implement {TASK-ID} - {task title}

### Requirements
{specific implementation requirements}

### Implementation Plan (from Review)
1. {step 1}
2. {step 2}
3. {step 3}

### Constraints
- {technical constraints}
- {compatibility requirements}
- {performance requirements}

### Files to Modify
1. `{file1}`
   - {what to modify}
2. `{file2}`
   - {what to modify}

### Acceptance Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}
- [ ] {criterion 3}

### Notes
- {risks from review phase}
- {edge cases to handle}
```

**Output Expected:**
- Modified/created files
- Implementation summary
- Any deviations from plan

### Phase 5: User Verification

**Actions:**
1. Present implementation summary
2. **Run the test files created in Phase 3.5** — show actual output
3. If tests fail: surface failures, do NOT proceed to close
4. If tests pass: present results and wait for user confirmation

**CRITICAL:** User saying "I'll test later" is NOT sufficient to close the ticket.
Tests must be executed and shown to pass within this phase.

**Output Template:**

```markdown
## Implementation Complete

### Summary
{what was implemented}

### Files Changed
- `{file1}`: {changes made}
- `{file2}`: {changes made}

### Test Results
```
{actual test runner output — e.g. pytest, jest, go test}
```
Status: ✓ PASS ({n} tests) / ✗ FAIL ({n} failed)

### How to Re-run Tests
```bash
{command to run tests}
```

**All tests passing. Please confirm to close ticket.**
```

**If tests fail:**

```markdown
## Tests Failed — Implementation Incomplete

### Failing Tests
{list failing test names and error output}

### Next Steps
Returning to Phase 4 to fix implementation.
```

### Phase 6: Close Ticket

**CRITICAL: Requires explicit user approval**

**User approval expressions:**
- "Confirmed", "OK", "Pass"
- "Close ticket", "Mark as done"
- "LGTM", "Approved"

**Forbidden auto-close scenarios:**
- Implementation complete but user hasn't tested
- User says "I'll test later"
- Unresolved issues exist

**Ticket Update Format:**

```markdown
### {TASK-ID}: {title}
- **Status**: Done
- **Completed**: {date}
- **Changes**:
  - {file 1}
  - {file 2}
- **Verified by**: User
```

## Parallel vs Serial Execution

### Parallel Allowed

When tasks are independent:

```
Parallel scenarios:
  Agent A: Review Module A design
  Agent B: Review Module B design
  Agent C: Review Module C design

Parallel scenarios:
  Agent A: Design tests for Feature A
  Agent B: Design tests for Feature B (no dependency on A)
```

**Criteria for parallel:**
- Different files, no shared dependencies
- Outputs don't affect each other
- One failure doesn't affect others

### Serial Required

When dependencies exist:

```
Correct serial execution:
Step 1: Agent A reviews design
   | Wait for completion, get implementation plan
Step 2: Agent B implements based on plan

Must be serial:
- Review -> Implementation (implementation needs review results)
- Implementation -> Testing (testing needs implementation complete)
- Infrastructure -> Business logic (business depends on infrastructure)
```

## Operations

### EXECUTE (Full Workflow)

```
1.  Read ticket, parse task details
2.  Call Plan Agent for review
3.  Wait for review completion
4.  Call Plan Agent for test design
5.  Wait for test design completion
6.  Call Code Agent to write test files (MANDATORY — cannot skip)
7.  Wait for test file creation
8.  Call Code Agent for implementation
9.  Wait for implementation completion
10. Run test files, capture output
11. If tests fail → return to step 8
12. If tests pass → present results + test output to user
13. Wait for explicit user approval
14. On approval, close ticket
```

### REVIEW (Phase 2 Only)

```
1. Read ticket, parse task details
2. Call Plan Agent for review
3. Output review results
4. Do not proceed to implementation
```

### TEST (Phase 3 Only)

```
1. Read ticket or feature description
2. Call Plan Agent for test design
3. Output test steps
```

### CLOSE

```
1. Verify user has approved
2. Update ticket status to Done
3. Record completion date
4. Update downstream dependencies
```

## Quick Templates

### Simple Task (Single File)

```markdown
Review modification to `{file path}`.

Purpose: {why modifying}

Checklist:
1. Syntax correctness
2. Logic completeness
3. Edge case handling
4. Compatibility with existing code

Output: Pass/Fail + Reason
```

### Bug Fix Template

```markdown
# Fix {TASK-ID}: {bug description}

## Reproduction Steps
{how to trigger bug}

## Expected Behavior
{what should happen}

## Actual Behavior
{what actually happens}

## Fix Plan
1. Locate problem code
2. Analyze root cause
3. Design fix
4. Implement fix
5. Verify fix

## Regression Testing
Ensure fix doesn't affect other functionality
```

## Best Practices

### Subagent Usage Principles

1. **Least Privilege**: Use Plan Agent for review, Code Agent only when files need modification
2. **Clear Boundaries**: Each subagent does one thing
3. **Result Verification**: Check subagent output meets expectations

### Common Mistakes

| Mistake | Consequence | Correct Approach |
|---------|-------------|------------------|
| Skip review, implement directly | Miss risk points | Review first, then implement |
| Parallel execute dependent tasks | Use outdated info | Wait for dependencies |
| Close ticket without user approval | User unaware | Wait for explicit approval |
| Vague test steps | Cannot verify | Make steps executable |

### Efficiency Tips

- Simple tasks can merge review and implementation (with user permission)
- Multiple independent small tasks can run in parallel
- Reuse test step templates to reduce repetition

## Message Templates

Uses `messages/{language}.json` keys:
- `task.phase_review`
- `task.phase_test`
- `task.phase_implement`
- `task.phase_verify`
- `task.awaiting_approval`
- `task.closed`
- `task.not_found`
- `task.dependency_not_met`
