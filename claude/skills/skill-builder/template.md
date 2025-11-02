# Skill Template

## Table of Contents
- [Basic Template](#basic-template)
- [Customization Checklist](#customization-checklist)
- [Optional Sections](#optional-sections)

## Basic Template

```markdown
---
name: skill-name-here
description: Use when user asks to "trigger phrase 1", "trigger phrase 2". Brief description of what this does and key functionality.
# Optional: allowed-tools: Read, Write, Edit, Bash
---

# Skill Name

Brief description (2-3 sentences).

## Process

1. **Step 1**: Description
2. **Step 2**: Description
3. **Step 3**: Description

## Guidelines

- **Key rule**: Explanation
- **Constraint**: Explanation

<critical>
Non-negotiable rules that must always be followed.
</critical>

## Examples

**Example 1: Simple case**
Input: [what user provides]
Output:
\`\`\`
[expected output]
\`\`\`

## Resources

For advanced options, see [reference.md](reference.md)
```

## Customization Checklist

Before using this template:

- [ ] Replace `skill-name-here` with kebab-case name
- [ ] Write explicit description with trigger conditions
- [ ] Choose freedom level (high/medium/low)
- [ ] Add tool restrictions if needed (`allowed-tools`)
- [ ] Define process steps
- [ ] Add guidelines and constraints
- [ ] Include examples if output format is specific
- [ ] Add TOC if file will be >100 lines

## Optional Sections

### Prerequisites
```markdown
## Prerequisites

Before using this skill:
- [ ] Requirement 1
- [ ] Requirement 2
```

### Conditional Workflows
```markdown
## Workflow

**For simple cases**: Do X
**For complex cases**: Do Y, then Z
```

### Inline Examples
```markdown
## Examples

**Example 1**:
Input: "User request"
Output:
\`\`\`language
code or output
\`\`\`
```

### Validation
```markdown
## Validation

After completion, verify:
- [ ] Check 1
- [ ] Check 2
```

### Live Commands
```markdown
## Context

Current structure:
!`tree -L 2`
```
