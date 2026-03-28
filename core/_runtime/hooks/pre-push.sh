#!/bin/sh
# Hook: pre-push
# Warns if task-list has unchecked tasks before pushing.
# Install: ln -s ../../ai-skills/core/_runtime/hooks/pre-push .git/hooks/pre-push

TASK_FILE=".ai/context/task-list.md"

if [ ! -f "$TASK_FILE" ]; then
  exit 0
fi

UNCHECKED=$(grep -c '^\- \[ \]' "$TASK_FILE" 2>/dev/null || echo 0)

if [ "$UNCHECKED" -gt 0 ]; then
  echo "[ai-skills] Warning: $UNCHECKED unchecked task(s) in task-list.md"
  echo "[ai-skills] Push anyway? (y/N)"
  exec < /dev/tty
  read answer
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
    echo "[ai-skills] Push aborted."
    exit 1
  fi
fi
