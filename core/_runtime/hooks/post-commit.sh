#!/bin/sh
# Hook: post-commit
# Triggers the review skill on the current diff if tech-spec exists.
# Install: ln -s ../../ai-skills/core/_runtime/hooks/post-commit .git/hooks/post-commit

CONTEXT_DIR=".ai/context"
SPEC_FILE="$CONTEXT_DIR/tech-spec.md"

# Only trigger if a tech-spec exists (means we're mid-pipeline)
if [ ! -f "$SPEC_FILE" ]; then
  exit 0
fi

echo "[ai-skills] tech-spec found, you can run: /review"
echo "[ai-skills] Or run the orchestrator to check pipeline state: /orchestrate"
