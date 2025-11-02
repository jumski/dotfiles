# Lovable Prompt Template

Use this template when generating individual prompts. Each prompt should be self-contained and follow the CLEAR framework.

## Standard Prompt Structure

```markdown
# [Feature/Component Name]

**Recommended Mode**: [Chat Mode / Default Mode]

---

## Context

**Project**: [Brief project description]

**Tech Stack**: [List frameworks, libraries, backend services]

**Knowledge Base**: This prompt builds on the project requirements documented in the Knowledge Base. Please review it before starting.

**Current State**: [What's already been built, if applicable]

---

## Task

[Clear, specific description of what this prompt should accomplish. ONE feature or component only.]

**Goal**: [The end result user should see or be able to do]

---

## Guidelines

**Implementation Details**:
- [Specific technical approach or pattern to use]
- [Component structure or file organization]
- [Data structures, types, or interfaces needed]

**Integration Requirements** (if applicable):
- Use `[Integration Name]` for [purpose]
- [Specific API key or setup requirements if needed]

**Styling & UX**:
- [Design requirements, responsiveness, accessibility]
- Use [UI library if specified, e.g., shadcn/ui, Tailwind CSS]

**Mock/Dummy Data Pattern** (for frontend prompts):
- Create mock adapter class/function: `[AdapterName]`
- Use hardcoded dummy data: `[example structure]`
- Ensure easy replacement in future backend integration prompts

---

## Constraints

**Do NOT modify**:
- `[File1.tsx]` - [Reason why it's off-limits]
- `[File2.tsx]` - [Reason why it's off-limits]
- [List any other files, components, or features that must remain untouched]

**Focus ONLY on**:
- `[File3.tsx]` - [The specific file(s) this prompt should create/modify]
- `[Component/Page]` - [The specific UI area]

**Behavior Constraints**:
- Keep existing functionality unchanged
- Do not introduce new dependencies unless specified above
- [Any other behavioral constraints]

---

## Deliverables Checklist

After completing this prompt, the following should be verifiable:

- [ ] [Specific UI element visible and matches design]
- [ ] [User can perform specific action and see result]
- [ ] [Data structure/mock adapter created with expected shape]
- [ ] [Responsive behavior works on mobile and desktop]
- [ ] [No errors in console, app runs without issues]

[Add 3-7 specific, human-readable verification steps that both the user and Lovable can check]

---

## Next Steps

After verification:
- [What the next prompt will tackle]
- [How this prompt's work will be built upon]

```

## Template Usage Notes

### For Phase 0 (Setup) Prompts

- Mode: Chat Mode
- Task: "Create Knowledge Base entry with project requirements"
- No code deliverables, just planning
- Checklist: "Knowledge Base contains PRD", "Tech stack confirmed", etc.

### For Frontend Mock Prompts

- Mode: Default Mode
- Task: "Build [Component] UI with dummy data"
- Guidelines: Include mock adapter pattern
- Constraints: Do NOT connect to real backend/APIs
- Checklist: Visual verification, interaction works with mock data

### For Backend Integration Prompts

- Mode: Default Mode
- Task: "Replace [MockAdapter] with real [Service] integration"
- Guidelines: Reference exact mock to replace
- Constraints: Keep frontend behavior identical
- Checklist: Real data displays, error handling works, auth flows correctly

### For Polish Prompts

- Mode: Default Mode (or Chat for discussion first)
- Task: "Make [Component] responsive" or "Improve [Feature] UX"
- Constraints: **Purely visual changes, do NOT alter functionality**
- Checklist: Visual verification across devices, no broken features

## Key Principles

1. **One Prompt = One Deliverable**: Never combine unrelated features
2. **Explicit Scope**: Always state what NOT to touch
3. **Human-Verifiable**: Checklists must be checkable by a human, not just "code works"
4. **Reference PRD**: Always mention Knowledge Base to ground the AI
5. **Clear Next Steps**: Help user understand the sequence

## Common Patterns

### Pattern: Mock Adapter
```typescript
// Create this pattern in frontend prompts:
class MockUserService {
  async getUsers() {
    return [
      { id: 1, name: "Alice", email: "alice@example.com" },
      { id: 2, name: "Bob", email: "bob@example.com" }
    ];
  }
}

// Replace in backend prompts:
class SupabaseUserService {
  async getUsers() {
    const { data } = await supabase.from('users').select('*');
    return data;
  }
}
```

### Pattern: Scope Constraint
```
Do NOT modify:
- `AuthProvider.tsx` (authentication is working correctly)
- `api/payments/*` (payment logic is stable and tested)
- `Layout.tsx` (layout structure should remain unchanged)

Focus ONLY on:
- `Dashboard.tsx` (new dashboard UI)
- `components/DashboardCard.tsx` (new component)
```

### Pattern: Integration Reference
```
Use `[Supabase]` for:
- User authentication (email/password)
- Database queries (users table, tasks table)
- Row Level Security for multi-tenant isolation

Setup requirements:
- SUPABASE_URL and SUPABASE_ANON_KEY in environment variables
- Users table schema: id, email, created_at, role
```
