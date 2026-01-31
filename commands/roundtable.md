---
description: "Orchestrate subagents to investigate questions and provide findings"
argument-hint: "{question}"
---

# /roundtable - Multi-Agent Investigation

Spawn multiple subagents to research a question through parallel investigation.

## Usage

```
/roundtable {question}
```

## Examples

```
/roundtable why is the particle not colliding with the mesh
/roundtable how does Niagara FLIP simulation work
/roundtable what's causing the plugin skill to not load
/roundtable explain the StreamingData architecture
```

## What It Does

1. Parses your question
2. Spawns parallel subagents:
   - Local code search
   - Web research
   - Source code review (UE, libraries)
3. Synthesizes findings
4. Outputs structured report

## Output

```markdown
## Roundtable: {question}

### Findings
{discoveries}

### Analysis
{interpretation}

### Recommendations
{suggestions}

### References
{files and links}
```

## Natural Language Alternatives

Instead of the command, you can say:

| Natural Language | Effect |
|------------------|--------|
| "调查一下 X" | Investigate X |
| "为什么 Y" | Find out why Y |
| "研究 Z" | Research Z |
| "Investigate X" | Same |
| "Why is Y" | Same |
| "Research Z" | Same |

## Implementation

Calls `roundtable/SKILL.md` for execution logic.
