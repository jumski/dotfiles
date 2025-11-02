# Complete Reference

## Table of Contents
- [Frontmatter Options](#frontmatter-options)
- [File Inclusion Syntax](#file-inclusion-syntax)
- [Command Rendering](#command-rendering)
- [XML Tags](#xml-tags)
- [Testing Checklist](#testing-checklist)
- [Token Budget Guidelines](#token-budget-guidelines)

## Frontmatter Options

```yaml
---
name: lowercase-with-hyphens      # Required
description: Trigger conditions   # Required
allowed-tools: Read, Write, Edit  # Optional: restrict tool access
---
```

**Description must include**:
- Trigger conditions ("Use when user asks to...")
- What the skill does
- Key capabilities

## File Inclusion Syntax

**Immediate inclusion** (always loaded):
```markdown
@supporting-file.md
```

**Conditional reference** (load on-demand) - PREFERRED:
```markdown
For details, see [reference.md](reference.md)
```

**Explicit direction**:
```markdown
If you encounter errors, consult [troubleshooting.md](troubleshooting.md)
```

## Command Rendering

Embed live command output:
```markdown
!`tree -L 2`
!`git branch --show-current`
!`ls -la src/`
```

## XML Tags

```markdown
<critical>
Non-negotiable constraints
</critical>

<output_format>
Expected output structure
</output_format>
```

## Testing Checklist

Before releasing a skill:
- [ ] Description includes trigger conditions
- [ ] SKILL.md is <200 lines
- [ ] Files >100 lines have TOC
- [ ] One level deep (no subdirectories)
- [ ] Test: Does it activate correctly?
- [ ] Test: Does it follow instructions?
- [ ] Test: Handle edge cases?

## Token Budget Guidelines

**Target**: <1,500 tokens initial load

**SKILL.md**: ~300-500 tokens (100-200 lines)
**Supporting file**: ~200-600 tokens each
**Total with 2 supporting**: ~700-1,700 tokens

**Optimization strategies**:
1. Keep SKILL.md focused
2. Move examples to separate file
3. Use conditional references
4. Add TOCs to enable previewing
5. Remove redundant content

## Directory Structure

**Personal skills**:
```
~/.claude/skills/skill-name/
├── SKILL.md
├── examples.md      # Optional
└── reference.md     # Optional
```

**Project skills**:
```
.claude/skills/skill-name/
├── SKILL.md
├── scripts/         # Optional: helper scripts
└── reference.md
```

## Common Mistakes

1. **No TOC** on files >100 lines
2. **Too broad** description
3. **Over-nesting** (subdirectories)
4. **Forced inclusion** (@file.md instead of file.md)
5. **No testing** before release
6. **Redundant content** across files
7. **Missing trigger** conditions in description
