#!/bin/bash
# Plan auto-resume — only for impl sessions
# Triggered by: SessionStart (new session, /clear, compaction)

# ── Gate 1: Session type check ──
if [ "$CLAUDE_SESSION_TYPE" != "impl" ]; then
  exit 0
fi

# ── Gate 2: Find latest active handoff (in-progress or NOT STARTED) ──
HANDOFF=$(ls -1t .claude/docs/handoff/*.md 2>/dev/null | while read f; do
  if grep -qE '^\*\*Status:\*\* (in-progress|NOT STARTED)' "$f"; then
    echo "$f"; break
  fi
done)

if [ -n "$HANDOFF" ]; then
  echo "<impl-session source=\"handoff\" file=\"$HANDOFF\">"
  cat "$HANDOFF"
  echo ""
  echo "Read the referenced plan file, then continue from Next Steps."
  echo "</impl-session>"
  exit 0
fi

# ── Gate 3: Find latest approved plan (first impl session) ──
PLAN=$(ls -1t .claude/docs/plan/*.md 2>/dev/null | while read f; do
  if grep -q 'approved' "$f"; then
    echo "$f"; break
  fi
done)

if [ -n "$PLAN" ]; then
  echo "<impl-session source=\"plan\" file=\"$PLAN\">"
  grep -E '(^\*\*Status:|^### Step|^- \[)' "$PLAN"
  echo ""
  echo "Read the full plan file and start from Step 1."
  echo "</impl-session>"
  exit 0
fi
