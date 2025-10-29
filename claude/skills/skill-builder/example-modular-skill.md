# Example: Modular Skill (Medium Freedom)

## Table of Contents
- [Use Case](#use-case)
- [Structure](#structure)
- [SKILL.md](#skillmd)
- [examples.md](#examplesmd)
- [Why This Works](#why-this-works)

## Use Case
React component generator following project patterns.

## Structure
```
component-generator/
├── SKILL.md       # Process + template
├── examples.md    # Component examples
└── reference.md   # Advanced patterns
```

## SKILL.md

```markdown
---
name: component-generator
description: Use when user asks to "create a component", "generate React component", or "scaffold component". Generates TypeScript React components following project patterns.
---

# Component Generator

Creates React components following project conventions.

## Process

1. Understand: purpose, props, state needs
2. Check existing patterns in codebase
3. Generate component with TypeScript
4. Validate TypeScript compiles

## Template

\`\`\`tsx
interface ComponentNameProps {
  requiredProp: string;
  optionalProp?: boolean;
}

export function ComponentName({
  requiredProp,
  optionalProp = false,
}: ComponentNameProps) {
  // Hooks at top
  // Event handlers
  // Render logic
  return <div>{/* JSX */}</div>;
}
\`\`\`

## Guidelines

- TypeScript with explicit prop interfaces
- Named exports (not default)
- Destructure props with defaults
- File location: `src/components/[Name]/`

<critical>
Never use `any` type. Always explicit types.
</critical>

## Examples

See [examples.md](examples.md) for complete examples.
For advanced patterns, see [reference.md](reference.md).
```

## examples.md

```markdown
# Component Examples

## Simple Button

\`\`\`tsx
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled?: boolean;
}

export function Button({ label, onClick, disabled = false }: ButtonProps) {
  return (
    <button onClick={onClick} disabled={disabled} className="btn">
      {label}
    </button>
  );
}
\`\`\`

## Form Input with Validation

\`\`\`tsx
interface TextInputProps {
  label: string;
  value: string;
  onChange: (value: string) => void;
  error?: string;
}

export function TextInput({ label, value, onChange, error }: TextInputProps) {
  const id = useId();
  return (
    <div>
      <label htmlFor={id}>{label}</label>
      <input
        id={id}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        aria-invalid={!!error}
      />
      {error && <span>{error}</span>}
    </div>
  );
}
\`\`\`
```

## Why This Works

- **Medium Freedom**: Template + customization
- **Token Efficient**: Examples loaded on-demand
- **One Level Deep**: SKILL.md → supporting files
- **Progressive**: Core in main file, details optional
