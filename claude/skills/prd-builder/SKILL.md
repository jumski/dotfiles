---
name: prd-builder
description: Create Product Requirement Documents through structured interview. Use when user says "create a PRD", "write a PRD for X", "document requirements for X", "start a PRD".
allowed-tools: Write, Bash
---

# PRD Builder

Guide user through structured interview, then generate PRD.

## Interview Sections

Ask questions in these areas, adapting based on product type:

**1. Product Overview**
- Name, what it does (1-2 sentences), primary user, problem solved

**2. Context & Motivation**
- Why now, alternatives, business impact, supporting data

**3. Goals & Metrics**
- Top 3 goals, success metrics, timeline, v1 definition

**4. User Stories**
- Primary user flow, key stories (As X, I want Y, so that Z), edge cases

**5. Requirements**
- Must-have (v1), nice-to-have (v2+), out of scope
- Performance, scale, security, accessibility

**6. Design & Technical**
- Mockups/wireframes, UX principles, platform (mobile/desktop)
- Integrations, tech stack, data storage, risks

**7. Dependencies & Constraints**
- External dependencies, deadlines, budget, resources

**8. Risks & Unknowns**
- Open questions, biggest risks, assumptions, failure modes

## Interview Tips

- **Probe vague answers** - "Can you be more specific?"
- **Skip irrelevant sections** - Internal tools may not need design/UX
- **Confirm understanding** - Summarize back to user
- **Note gaps** - Mark areas needing research
- **Stay focused** - Keep under 20 minutes

## After Interview

1. Synthesize into PRD using [template.md](template.md)
2. Ask user: "Where should I save this PRD?" (get directory path or full file path)
3. Save to: `<user-provided-path>/<product-name-kebab-case>.md`
4. Confirm saved location with user
