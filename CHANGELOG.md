# Changelog

All notable changes to ai-skills will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
versioning follows [Semantic Versioning](https://semver.org/).

---

## [0.2.0] - 2026-03-29

### Added
- `review-standard` skill: code review with BLOCK/SUGGEST/NITPICK severity levels, spec alignment check, with examples
- `release-conventional` skill: Conventional Commits changelog generation + deployment checklist, with examples
- `README.md`: integration guide in Chinese (quick start, daily usage, FAQ)
- `OVERVIEW_CN.md`: full architecture document in Chinese

---

## [0.1.0] - 2026-03-28

### Added
- Initial project structure: artifact schema, skill template, orchestrator, git hooks
- `prd-from-idea` skill: raw-idea → PRD
- `spec-from-prd` skill: PRD + optional design assets → tech-spec
- `plan-from-spec` skill: tech-spec → task-list with phase ordering and risk register
- Pipelines: `full-sdlc`, `planning-only`, `quick-review`
- `setup.sh`: one-command host project initialization
- `CONTRIBUTING.md`: guide for adding new skills
- `OVERVIEW.md`: living architecture document (EN)
