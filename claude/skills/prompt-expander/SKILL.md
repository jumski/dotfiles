---
name: prompt-expander
description: Use when user provides a simple, vague prompt and asks to expand/improve it, or when preparing prompts for another session. Triggers on "expand this prompt", "make this more specific", "improve this prompt", or similar requests.
---

# Prompt Expander

## Overview

Transform vague prompts into structured prompts that demand specific, actionable outputs. The goal: eliminate follow-up questions by forcing complete answers upfront.

## Core Transformation Pattern

```
VAGUE INPUT                    STRUCTURED OUTPUT
─────────────────────────────────────────────────────
"Tell me about X"         →    "Analyze X and provide:
                                1. [Specific section]
                                2. [Table with columns]
                                3. [Direct verdict]"

"Should I do X?"          →    "Answer directly: Should I X?
                                If yes: [specific items]
                                If no: [what instead]"

"Help me with X"          →    "Provide:
                                - [Concrete deliverable 1]
                                - [Concrete deliverable 2]
                                - [Decision framework]"
```

## Expansion Checklist

For each vague prompt, apply these transformations:

| Vague Element | Expand To |
|---------------|-----------|
| Open question | Direct verdict + reasoning |
| "Analyze X" | Numbered sections with specific asks |
| Comparison needed | Table with explicit columns |
| Decision to make | Binary answer + action items for each path |
| "What should I do?" | Prioritized list with specific next steps |
| Context provided | Require extraction of specific data points |
| "Any tips?" | Numbered list with exact count (e.g., "List 5 specific...") |

## Structure Injection

Always add explicit structure demands:

```markdown
## Required Output Structure

### 1. SECTION NAME (constraint)
- What exactly to include
- Word/item limits if relevant

### 2. ANALYSIS TABLE
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
(Describe what rows should contain)

### 3. VERDICT
Answer directly: [Yes/No question framing]

### 4. DELIVERABLES
- Concrete output 1 (e.g., "Write 2-3 sentences I could use to...")
- Concrete output 2 (e.g., "List 5 questions that...")
```

## Deliverable Types

Force concrete outputs, not just analysis:

- **Scripts/templates**: "Write the exact words I should say when..."
- **Checklists**: "List items to verify before..."
- **Questions to ask**: "List N specific questions that [criteria]"
- **Red flags**: "What signals would indicate [negative outcome]?"
- **Decision criteria**: "How do I know when to [action]?"

## Constraint Injection

Add specificity through constraints:

- Word limits: "(2-3 sentences max)"
- Item counts: "List exactly 5..."
- Format requirements: "Present as a table with columns..."
- Directness demands: "Answer directly:", "Recommend ONE with reasoning"
- Scope limits: "Focus only on...", "Do not include..."

## Anti-Patterns to Fix

| Vague Pattern | Fix |
|---------------|-----|
| "What do you think about X?" | "Provide verdict: [specific question]. Support with [evidence type]." |
| "Any advice?" | "List [N] specific recommendations, each with [format]." |
| "Help me understand X" | "Explain X by answering: 1. [specific Q] 2. [specific Q]..." |
| "Is this good?" | "Evaluate against criteria: [list]. Rate each. Provide overall verdict." |
| No structure | Add "## Required Output Structure" with numbered sections |
| No deliverables | Add "## Deliverables" with concrete outputs |

## Example Transformation

**Before:**
```
analyze the dreambase lead and tell me if i should prepare anything for the call
```

**After:**
```markdown
# Interview Prep Analysis

Analyze these files and provide:

## Required Output Structure

### 1. STRATEGIC CONTEXT (2-3 sentences max)
- Who reached out to whom and why?
- What's the power dynamic?

### 2. FIT ANALYSIS TABLE
| Requirement | My Strength | Gap? | How to Frame |
|-------------|-------------|------|--------------|

### 3. PREPARATION VERDICT
Answer directly: Should I prepare extensively, or go natural?
- If prepare: What exactly? (bullet list)
- If natural: What mindset to hold?

### 4. DELIVERABLES
- Write 2-3 sentences for call opening
- List 5 questions to ask them
- List red flags to watch for
```

## Process

1. **Identify the real question** - What does user actually need to decide/know?
2. **Break into discrete parts** - Each part becomes a numbered section
3. **Add structure demands** - Tables, lists, verdicts
4. **Force deliverables** - Concrete outputs user can use directly
5. **Add constraints** - Limits, counts, directness requirements
6. **Include reference files** - If user mentioned files, keep the @ references
