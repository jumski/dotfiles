# Patterns & Anti-Patterns

## Table of Contents
- [Freedom Levels](#freedom-levels)
- [Examples Pattern](#examples-pattern)
- [Common Patterns](#common-patterns)
- [Anti-Patterns](#anti-patterns)

## Freedom Levels

**High Freedom** - Creative/adaptive tasks:
```markdown
Review code focusing on issues most relevant to this change.
Use your judgment to determine depth based on complexity.
```

**Medium Freedom** - Pattern-based:
```markdown
Follow this template, customizing based on requirements:
[template here]
```

**Low Freedom** - Exact execution:
```markdown
Run exactly these commands in order. Do NOT modify:
1. `command1`
2. `command2`
```

## Examples Pattern

Show input/output pairs for pattern recognition:

```markdown
## Examples

**Example 1: Simple case**
Input: [user request]
Output:
\`\`\`
[exact desired output]
\`\`\`

**Example 2: Complex case**
Input: [complex scenario]
Output:
\`\`\`
[corresponding output]
\`\`\`
```

## Common Patterns

### Conditional Workflow
```markdown
If condition X:
  Do Y
Otherwise:
  Do Z
```

### Progressive Disclosure
```markdown
For basic usage, see above.
For advanced options, see [reference.md](reference.md)
```

### Command Rendering
```markdown
Project structure:
!`tree -L 2 -I 'node_modules'`
```

### XML Tags for Critical Rules
```markdown
<critical>
NEVER modify files in vendor/ directory.
</critical>
```

## Anti-Patterns

### ❌ Missing TOC (files >100 lines)
```markdown
# Long File

[400 lines of content with no navigation]
```

### ✅ With TOC
```markdown
# Long File

## Table of Contents
- [Section 1](#section-1)
- [Section 2](#section-2)
```

### ❌ Vague Description
```yaml
description: Helps with code reviews
```

### ✅ Specific Triggers
```yaml
description: Use when user asks to "review code", "check for bugs",
or "analyze implementation". Provides structured code review feedback.
```

### ❌ Over-Nesting
```
skill/
├── SKILL.md
└── guides/
    └── advanced/
        └── details.md  # Too deep!
```

### ✅ Flat Structure
```
skill/
├── SKILL.md
├── guide.md
└── advanced.md
```

### ❌ Forced Inclusion
```markdown
@huge-reference.md  # Always loaded
```

### ✅ On-Demand
```markdown
See [reference.md](reference.md) for details
```
