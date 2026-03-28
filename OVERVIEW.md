# ai-skills — Living Architecture Document

> **This file is always up to date.** It reflects the current state of the system:
> architecture decisions, integration guide, and lessons learned.
> Updated after every meaningful change.

---

## What This Is

A composable, model-agnostic toolkit of AI skills that covers the full software
development lifecycle. Skills are atomic transforms: each takes one or more
**artifact types** as input and produces exactly one artifact type as output.
Any stage can be replaced or skipped. Pipelines are assembled from skills like
Unix pipes.

**Core philosophy:**
- Skills are functions, not scripts
- Artifacts are the interface protocol
- Humans can intervene at any point
- No vendor lock-in (model-agnostic by default)

---

## Architecture

### Three Layers

```
┌─────────────────────────────────────────────┐
│  Pipeline  (pipelines/*.yaml)               │
│  Declares stage order and skill assignment  │
├─────────────────────────────────────────────┤
│  Skills  (skills/*/skill.yaml + prompt.md)  │
│  Atomic transforms: artifact → artifact     │
├─────────────────────────────────────────────┤
│  Artifact Schema  (core/_schema/artifacts)  │
│  Type system — what can flow between skills │
└─────────────────────────────────────────────┘
```

### Artifact Flow (default full-sdlc pipeline)

```
raw-idea
  └─[prd-from-idea]──► prd
                         └─[spec-from-prd]──► tech-spec
                                               └─[plan-from-spec]──► task-list
                                                                        │ (human)
                                                                     code-diff
                                                                        └─[review-standard]──► review
                                                                                                └─[release-conventional]──► release-notes
```

Optional inputs shown with `?`:
- `design-assets?` feeds into `spec-from-prd`
- `tech-spec?` feeds into `review-standard`

### Runtime State Machine

State lives in `.ai/context/` in the **host project** (never in this repo).

```
artifact file missing  →  stage PENDING
all required inputs exist  →  stage READY
skill running  →  stage RUNNING
artifact file written  →  stage DONE
artifact file deleted  →  stage PENDING (resets downstream too)
```

The orchestrator (`core/_runtime/orchestrator.md`) reads current context state
and determines what is ready to run — exactly like Make evaluating targets.

**Human override:** Add `# LOCKED` as the first line of any artifact file.
The orchestrator will never overwrite it.

---

## Repository Structure

```
ai-skills/
  core/
    _schema/
      artifacts.yaml        ← All artifact type definitions
    _runtime/
      orchestrator.md       ← Orchestrator skill (self-referential)
      hooks/
        post-commit.sh      ← Suggests /review after commit
        pre-push.sh         ← Warns on unchecked tasks
  skills/
    prd-from-idea/          ← raw-idea → prd
    spec-from-prd/          ← prd → tech-spec
    plan-from-spec/         ← tech-spec → task-list
    skill-template/         ← Copy this to add a new skill
  pipelines/
    full-sdlc.yaml          ← Complete pipeline
    planning-only.yaml      ← spec + plan only
    quick-review.yaml       ← review + release only
  setup.sh                  ← One-command setup for host projects
  CONTRIBUTING.md
  OVERVIEW.md               ← This file
```

---

## How to Integrate Into Your Project

### Option A: Git Submodule (recommended)

```bash
# Add as submodule
git submodule add git@github.com:Empty0Qc/ai-skills.git ai-skills

# Run setup
sh ai-skills/setup.sh
```

This creates:
- `.ai/context/` — runtime state (gitignored in your project)
- `.ai/pipeline.yaml` — which pipeline/skills to use (committed)
- Optional git hooks

### Option B: Clone directly

```bash
git clone git@github.com:Empty0Qc/ai-skills.git ai-skills
sh ai-skills/setup.sh
```

No submodule tracking. Simpler but manual updates.

### Updating the submodule

```bash
cd ai-skills && git pull && cd ..
git add ai-skills
git commit -m "chore: update ai-skills to latest"
```

### Host project gitignore entries needed

```gitignore
# ai-skills runtime state (added by setup.sh)
.ai/context/
```

The `.ai/pipeline.yaml` config file **should** be committed — it records
which pipeline and skill overrides your project uses.

---

## Skill Contract Reference

Each skill declares a type signature in `skill.yaml`:

```yaml
consumes:
  - prd           # required
  - design-assets?  # optional (? suffix)
produces:
  - tech-spec     # always exactly one
```

The `?` suffix means the skill can run without that input, but will produce
richer output if it's present.

**Swapping skills:** Any skill that satisfies the same contract is a drop-in
replacement. Override in `.ai/pipeline.yaml`:

```yaml
use: ai-skills/pipelines/full-sdlc.yaml
overrides:
  requirements:
    skill: prd-from-jira    # swap in your custom skill
```

---

## Current Skills

| Skill | Consumes | Produces | Status |
|-------|----------|----------|--------|
| `prd-from-idea` | `raw-idea` | `prd` | ✅ v0.1.0 |
| `spec-from-prd` | `prd`, `design-assets?` | `tech-spec` | ✅ v0.1.0 |
| `plan-from-spec` | `tech-spec` | `task-list` | ✅ v0.1.0 |
| `review-standard` | `code-diff`, `tech-spec?` | `review` | 🚧 planned |
| `release-conventional` | `review`, `task-list?` | `release-notes` | 🚧 planned |

---

## Current Pipelines

| Pipeline | Stages | Use When |
|----------|--------|----------|
| `full-sdlc` | idea→prd→spec→plan→review→release | New feature from scratch |
| `planning-only` | prd→spec→plan | You have PRD, need tech breakdown |
| `quick-review` | review→release | Just need review + changelog |

---

## Decisions & Trade-offs

### Why MD files for artifact state, not a database?

Git-native, human-readable, zero infrastructure. The `.ai/context/` directory
is like a build cache — throw it away and it regenerates. Structured data
needs (e.g., task tracking integration) can be layered on top via MCP later.

### Why "exactly one output per skill"?

Keeps the graph acyclic and predictable. If a skill naturally produces multiple
artifacts (e.g., spec + task list at once), it should be split into two skills
and composed via a pipeline. This makes individual skills testable in isolation.

### Why YAML for skill contracts, not TypeScript/JSON Schema?

Human-editable without tooling. Contributors can add a skill with just a text
editor. Schema validation can be added later without changing the format.

### Why not use LangChain / LlamaIndex / etc.?

This is a **prompt engineering system**, not an ML framework. The "runtime" is
the AI model itself. Adding a framework would add abstraction without benefit
at this layer. MCP integration for external tool access is on the roadmap and
is a better fit than a Python orchestration framework.

---

## Lessons Learned

*(Updated as we build)*

- **2026-03-28** — Initial architecture established. Key insight: defining artifact
  types as the interface protocol (not skill names) is what makes the system
  composable. Skills are implementation details; artifacts are the API.
- **2026-03-28** — Published to GitHub (`git@github.com:Empty0Qc/ai-skills.git`) and
  wired into mk_p as a git submodule. Host project gitignores `.ai/context/` (runtime
  state) but commits `.gitmodules` and the submodule reference. Gotcha: `git submodule add`
  fails if `.git/modules/{name}` has leftover state from a failed attempt — must
  `rm -rf .git/modules/ai-skills` before retrying.

---

## Roadmap

- [ ] `review-standard` skill
- [ ] `release-conventional` skill
- [ ] Orchestrator as a Claude Code skill (so `/orchestrate` works)
- [ ] Test runner for examples/
- [ ] `prd-from-figma` skill (MCP Figma integration)
- [ ] GitHub Actions workflow for CI on skill PRs
- [ ] VSCode extension for pipeline status visualization
