# Demo App Copywriting Context

## Project: pgflow

Database-centric workflow orchestration for Supabase. Replaces external control planes with zero-deployment SQL-native engine.

## Target Audience: Hacker News (Show HN)

Technical developers who value:

- Technical depth over marketing fluff
- Concrete examples over abstract benefits
- Honest trade-offs over pure selling
- Simple solutions over complex abstractions
- Postgres-native approaches

## Core Positioning (from landing page)

**Headline:** "Dead-simple workflow orchestration for Supabase"
**Tagline:** "AI workflows you can actually debug. Build reliable LLM chains and RAG pipelines with zero external services."

**Unique Value:**

- Runs entirely in Supabase (no Bull, Redis, Temporal, Railway)
- Reduces 200+ lines of boilerplate to ~20 lines
- Full observability in SQL (no hidden state, no external dashboards)
- <100ms startup, automatic retries, parallel array processing

## Key Differentiators

1. **No manual wiring** - Skip tedious pg_cron → pgmq → Edge Function setup
2. **Postgres-first** - Everything in your existing Supabase project
3. **SQL observability** - Query execution history, inspect outputs, debug with SQL
4. **Built-in reliability** - Retries with exponential backoff, per-item failure handling
5. **Developer experience** - TypeScript DSL, type inference, no boilerplate

## Copywriting Guidelines for HN Audience

### DO:

- Use technical, precise language
- Show concrete code examples
- Mention specific technologies (pgmq, pg_cron, Edge Functions)
- Explain how it works, not just what it does
- Be honest about limitations and trade-offs
- Use phrases like "here's how it works" not "experience the power"
- Emphasize Postgres-native approach
- Focus on reducing boilerplate and complexity

### DON'T:

- Use sales-pitchy language ("revolutionize", "game-changing", "unlock")
- Make exaggerated claims
- Use excessive exclamation marks
- Oversimplify technical concepts
- Hide limitations
- Use marketing speak ("streamline", "leverage", "empower")
- Overuse superlatives ("best", "fastest", "most powerful")

### Tone:

- Matter-of-fact, not enthusiastic
- Informative, not persuasive
- Respectful of reader's intelligence
- Direct and concise
- Technical but accessible

## Code Location

All demo app code is in `apps/demo/`

## Current Focus

Mobile view (narrowest viewport) - onboarding modals, success modals, explanation panels for steps.

## Example Transformations

**Sales-pitchy (avoid):**
"Unlock the power of workflow orchestration with pgflow!"

**HN-appropriate (prefer):**
"pgflow is workflow orchestration that runs in Postgres. No external services required."

---

**Sales-pitchy (avoid):**
"Experience seamless integration with Supabase!"

**HN-appropriate (prefer):**
"Integrates with Supabase using pgmq for queues and Edge Functions for workers."

---

**Sales-pitchy (avoid):**
"Transform your workflows with our revolutionary approach!"

**HN-appropriate (prefer):**
"Replace 200+ lines of queue management code with a TypeScript DSL."

## Request Format

When requesting changes, structure as:

1. Component/file being edited (in `apps/demo/`)
2. Current copy that needs improvement
3. Specific issue (too sales-y, unclear, not HN-appropriate)
4. Context about where it appears in the UI

---

<USER_REQUEST>
$ARGUMENTS
</USER_REQUEST>
