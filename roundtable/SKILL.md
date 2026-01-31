---
name: roundtable
version: "1.0.0"
description: Orchestrate multiple subagents to investigate questions, analyze problems, and provide findings with recommendations.
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
  - WebSearch
  - WebFetch
---

# Roundtable - Multi-Agent Investigation

Orchestrate multiple subagents to investigate questions through parallel research: local code analysis, web search, and source code review.

## Trigger Conditions

- User calls `/roundtable` command
- User asks investigation questions with natural language

## Natural Language Understanding

### Investigation (zh)
- "调查 {question}"
- "研究一下 {topic}"
- "为什么 {problem}"
- "分析 {subject}"
- "找出 {issue} 的原因"
- "搞清楚 {thing}"

### Investigation (en)
- "investigate {question}"
- "research {topic}"
- "why is {problem}"
- "analyze {subject}"
- "find out why {issue}"
- "figure out {thing}"

## Workflow

```
1. Parse Question
   |
   v
2. Spawn Subagents (Parallel)
   |-- Agent A: Local code search (Glob, Grep, Read)
   |-- Agent B: Web research (WebSearch, WebFetch)
   |-- Agent C: Source code review (Read UE/library source)
   |
   v
3. Synthesize Findings
   |
   v
4. Output Report
```

## Execution Steps

### Step 1: Parse Question

Identify:
- What is being asked
- Relevant keywords for search
- Scope (local code, external docs, or both)

### Step 2: Spawn Subagents

Launch Plan agents in parallel:

**Agent A - Local Code Analysis:**
```
Search the local codebase for {keywords}.
Find relevant files, patterns, and implementations.
Report: file locations, code snippets, relationships.
```

**Agent B - Web Research:**
```
Search web for {topic} documentation and solutions.
Find official docs, community solutions, best practices.
Report: key information, links, recommendations.
```

**Agent C - Source Code Review (if applicable):**
```
Search engine/library source code at {path}.
Find implementation details, API usage patterns.
Report: how it works internally, correct usage.
```

### Step 3: Synthesize Findings

Combine results from all agents:
- Identify common themes
- Resolve conflicting information
- Build complete picture

### Step 4: Output Report

```markdown
## Roundtable: {question}

### Findings
{key discoveries from all agents}

### Analysis
{synthesis and interpretation}

### Recommendations
{suggested actions or conclusions}

### References
- {file/link 1}
- {file/link 2}
```

## Scope

### IN Scope (READ-ONLY)
- Read local files
- Search codebase
- Web search and fetch
- Analyze and synthesize
- Provide recommendations

### OUT of Scope (NO modifications)
- Write/Edit files
- Git operations
- Create tickets
- Implement solutions
- Run builds or tests

## Agent Configuration

| Agent | Type | Tools | Purpose |
|-------|------|-------|---------|
| Local Code | Explore | Glob, Grep, Read | Find relevant code |
| Web Research | Plan | WebSearch, WebFetch | External documentation |
| Source Review | Explore | Glob, Grep, Read | Engine/library internals |

## Message Templates

Uses `messages/{language}.json` keys:
- `roundtable.started`
- `roundtable.agents_spawned`
- `roundtable.synthesizing`
- `roundtable.complete`
