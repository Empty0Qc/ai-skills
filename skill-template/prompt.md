# Skill: your-skill-name

## Role

Describe the role this skill plays. Be specific about the persona and constraints.

## Input

The following artifacts are available in `.ai/context/`:

{{#each consumes}}
### {{this.type}}{{#if this.optional}} (optional){{/if}}
{{this.content}}
{{/each}}

## Task

Describe exactly what the skill should do. Use numbered steps for complex tasks.

1. Step one
2. Step two
3. Step three

## Output Format

Describe the exact format for the output artifact. Include a template if helpful.

```markdown
# Title

## Section 1

...
```

## Quality Criteria

What makes a good output? List 3-5 criteria. The skill should self-check against these
before writing the final output.

- Criterion 1
- Criterion 2
- Criterion 3

## Constraints

- Do not hallucinate technical details not present in the input
- If input is ambiguous, list your assumptions at the top of the output
- Mark any section that needs human review with `<!-- REVIEW NEEDED: reason -->`
