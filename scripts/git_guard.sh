#!/bin/bash
# Git Guard - Intercept git commit/push commands
# This script is called by Claude Code's PreToolUse hook

# Read tool_input JSON from stdin
input=$(cat)

# Extract command field using jq (if available) or grep
if command -v jq &> /dev/null; then
  command_str=$(echo "$input" | jq -r '.tool_input.command // empty')
else
  command_str=$(echo "$input" | grep -oP '"command"\s*:\s*"\K[^"]+')
fi

# Check for git commit (requires confirmation)
if echo "$command_str" | grep -qE 'git\s+commit'; then
  echo '{"decision": "block", "reason": "Git commit requires user confirmation"}'
  exit 0
fi

# Check for git push (requires confirmation)
if echo "$command_str" | grep -qE 'git\s+push'; then
  echo '{"decision": "block", "reason": "Git push requires user confirmation"}'
  exit 0
fi

# Check for force push (blocked)
if echo "$command_str" | grep -qE 'git\s+push\s+.*--force'; then
  echo '{"decision": "block", "reason": "Force push is blocked unless explicitly requested"}'
  exit 0
fi

# Check for hard reset (blocked)
if echo "$command_str" | grep -qE 'git\s+reset\s+--hard'; then
  echo '{"decision": "block", "reason": "Hard reset is blocked unless explicitly requested"}'
  exit 0
fi

# Check for interactive rebase (blocked - not supported)
if echo "$command_str" | grep -qE 'git\s+rebase\s+-i'; then
  echo '{"decision": "block", "reason": "Interactive rebase is not supported"}'
  exit 0
fi

# Allow all other commands
echo '{"decision": "allow"}'
