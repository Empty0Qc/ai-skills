#!/bin/sh
# setup.sh — Run this in your host project to wire up ai-skills
# Usage: sh ai-skills/setup.sh

set -e

echo "[ai-skills] Setting up in $(pwd)..."

# 1. Create .ai/context directory (runtime state, gitignored)
mkdir -p .ai/context

# 2. Add .ai/context to host project's gitignore
if [ -f ".gitignore" ]; then
  if ! grep -q "^\.ai/context" .gitignore; then
    echo "\n# ai-skills runtime state\n.ai/context/" >> .gitignore
    echo "[ai-skills] Added .ai/context/ to .gitignore"
  fi
else
  echo "# ai-skills runtime state\n.ai/context/" > .gitignore
  echo "[ai-skills] Created .gitignore with .ai/context/"
fi

# 3. Create default pipeline config
if [ ! -f ".ai/pipeline.yaml" ]; then
  cat > .ai/pipeline.yaml << 'EOF'
# Active pipeline for this project.
# Change 'use' to switch pipelines, or add 'overrides' to customize stages.

use: ai-skills/pipelines/full-sdlc.yaml

# Example override: swap the PRD skill
# overrides:
#   requirements:
#     skill: prd-from-jira
EOF
  echo "[ai-skills] Created .ai/pipeline.yaml"
fi

# 4. Install git hooks (optional)
if [ -d ".git/hooks" ]; then
  echo "[ai-skills] Install git hooks? (y/N)"
  read answer
  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    ln -sf "../../ai-skills/core/_runtime/hooks/post-commit.sh" .git/hooks/post-commit
    ln -sf "../../ai-skills/core/_runtime/hooks/pre-push.sh" .git/hooks/pre-push
    chmod +x .git/hooks/post-commit .git/hooks/pre-push
    echo "[ai-skills] Hooks installed."
  fi
fi

echo "[ai-skills] Done. Start with: create .ai/context/raw-idea.md, then run /prd"
