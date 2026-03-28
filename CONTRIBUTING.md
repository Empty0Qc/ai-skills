# Contributing a Skill

A skill is a directory under `skills/` with two required files:

```
skills/your-skill-name/
  skill.yaml      ← contract declaration
  prompt.md       ← the actual prompt
  examples/
    input/        ← sample input artifacts (for testing)
    output/       ← expected output (golden file)
```

## Steps

1. Copy `skill-template/` to `skills/your-skill-name/`
2. Fill in `skill.yaml` — pay careful attention to `consumes` and `produces`
3. Write `prompt.md` — see existing skills for patterns
4. Add at least one example in `examples/`
5. Open a PR with the title `feat(skill): your-skill-name`

## Contract Rules

- `consumes` and `produces` must reference types defined in `core/_schema/artifacts.yaml`
- If you need a new artifact type, add it to the schema in the same PR
- `produces` must be exactly one artifact (skills are single-output transforms)
- Breaking a contract (changing `consumes`/`produces`) requires a major version bump

## Versioning

- Patch (`0.1.x`): typo fixes, clarity improvements
- Minor (`0.x.0`): prompt behavior changes, new optional inputs
- Major (`x.0.0`): contract changes (different consumes/produces)

## Testing

Run your skill against the examples:

```bash
# Coming soon: test runner
```

For now: manually run your skill with the example inputs and compare to example outputs.
