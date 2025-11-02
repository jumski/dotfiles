---
name: skill-builder
description: Use when user asks to "create a skill", "build a skill", or "design a skill". Guides through requirements, solution design, and implementation of token-efficient Claude Code skills.
---

# Skill Builder

Create high-quality, token-efficient Claude skills.

**Current structure**:
!`tree -L 1 ~/.claude/skills/skill-builder -I 'example-*'`

## Quick Mode vs. Guided Mode

**Quick Mode** (for simple skills):
1. Ask: Purpose, trigger conditions, freedom level
2. Use [template.md](template.md) and create immediately

**Guided Mode** (for complex skills):
Follow 3-phase process below

## Guided Process

### Phase 1: Requirements (via AskUserQuestion tool)

<critical>
Use AskUserQuestion tool for all requirement gathering.
Interactive buttons prevent ambiguity and force clear decisions.
Ask as many questions as needed to clarify requirements and design decisions.
</critical>

Core questions (always ask):

1. **What & When**: Purpose and trigger conditions
2. **Freedom level**: High (creative) / Medium (pattern) / Low (scripted)
3. **Scope**: Personal (~/.claude/skills) or project (.claude/skills)

Additional questions (ask when relevant):

- Tool permissions needed?
- Expected token budget?
- Multiple modes/approaches?
- Integration with other skills?
- Example scenarios to handle?

Example using AskUserQuestion:
```
question: "What level of freedom should this skill have?"
options:
  - label: "High (creative)"
    description: "Skill makes autonomous decisions, adapts to context"
  - label: "Medium (pattern)"
    description: "Follows established patterns with some flexibility"
  - label: "Low (scripted)"
    description: "Strictly follows predefined steps"
```

### Phase 2: Propose Pattern

Choose based on complexity:
- **Simple** (<200 lines): Single SKILL.md | See [example-simple.md](example-simple.md)
- **Modular** (needs examples): SKILL.md + supporting files | See [example-modular.md](example-modular.md)
- **Scripted** (fragile ops): Add helper scripts | See [example-scripted.md](example-scripted.md)

### Phase 3: Create

1. Create directory and SKILL.md using [template.md](template.md)
2. Add supporting files if modular/scripted
3. Verify: description has triggers, TOC added if >100 lines

## Critical Rules

<critical>
- Description MUST include trigger conditions ("Use when user asks to...")
- Files >100 lines MUST have table of contents
- One level deep only (SKILL.md → supporting files, no subdirectories)
- SKILL.md should be <200 lines
- Use reference.md not @reference.md (load on-demand)
</critical>

## Resources

**Examples** (real-world patterns):
- [example-simple.md](example-simple.md) - Single file, high freedom
- [example-modular.md](example-modular.md) - Multi-file with examples
- [example-scripted.md](example-scripted.md) - Helper scripts for fragile ops

**Guides** (details on-demand):
- [template.md](template.md) - Blank SKILL.md starter
- [patterns.md](patterns.md) - Common patterns and anti-patterns
- [reference.md](reference.md) - Complete options reference
