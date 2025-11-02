# Example: Simple Skill (High Freedom)

Single-file skill for creative tasks with high autonomy.

## Use Case
Git commit message helper following conventional commits format.

## Structure
```
commit-helper/
└── SKILL.md (single file)
```

## SKILL.md

```markdown
---
name: commit-helper
description: Use when user asks to "create a commit", "write commit message", or "commit changes". Generates conventional commit messages from git changes.
---

# Commit Message Helper

Analyzes staged changes and creates clear, conventional commit messages.

## Process

1. Run `git diff --staged` to see changes
2. Determine type (feat/fix/refactor/docs/test/chore)
3. Identify scope if changes are focused
4. Write concise message (imperative, lowercase, <50 chars)

## Format

\`\`\`
type(scope): subject line

Optional body explaining why, not what.
\`\`\`

## Examples

**Simple**:
\`feat(auth): add JWT token validation\`

**With detail**:
\`\`\`
fix(api): prevent race condition in session handling

Session validation was occurring before data fully loaded.
Now awaits initialization before validation.

Fixes #123
\`\`\`

Use judgment for detail level based on change complexity.
```

## Why This Works

- **High Freedom**: Claude adapts to different change types
- **Clear Process**: Simple 4-step workflow
- **Examples**: Show pattern without over-prescribing
- **Single File**: Simple task needs no decomposition
- **<200 lines**: Well under target
