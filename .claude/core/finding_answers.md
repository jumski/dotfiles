# Finding Answers - Decision Tree

## Quick Decision Tree

```
What am I looking for?

├─ Documentation for a tool/library?
│  ├─ Fish shell, Fisher, Fishtape? → Context7 MCP or Perplexity
│  ├─ Tmux, Git, CLI tools? → Context7 MCP or Perplexity
│  └─ Other library/framework? → Context7 MCP
│
├─ Content from a specific URL? → URL Crawler*
│
└─ Generic search/question? → Perplexity Search

*Check if library docs first - use Context7 instead
```

## When to Use Tools vs Answer Directly

**Default: Answer from your training knowledge WITHOUT tools.**

**ONLY use search/research tools when user explicitly signals intent:**
- "search for..."
- "find..."
- "look up..."
- "research..."
- "what's the latest..."
- "current best practices..."
- User provides a URL to crawl/fetch

**CRITICAL: DO NOT use WebFetch to fetch documentation you know about:**
- "ask for info about X" → Answer directly or use appropriate MCP (NOT WebFetch)
- "tell me about X" → Answer directly (NOT WebFetch)
- WebFetch is ONLY for when user explicitly provides a URL to fetch
- For Fish/Tmux/Git docs → Answer from knowledge or use Context7/Perplexity if needed

**ALWAYS use MCP tools for specific systems:**
- Questions about Fish shell → Context7 MCP or Perplexity
- Questions about specific tools (tmux, git, etc.) → Context7 MCP or Perplexity

## Tool Selection Hierarchy

**ALWAYS follow this order. Never skip steps.**

| Priority | Scenario | Tool | Notes |
|----------|----------|------|-------|
| 1 | Library/framework docs | Context7 MCP (`resolve-library-id` → `get-library-docs`) | Token limits: 3k-10k, use `topic` param |
| 2 | Generic search | Perplexity Search | `max_results: 3`, `max_tokens_per_page: 512` |
| 3 | Conversational answer | Perplexity Ask | When Search returns nothing |
| 4 | Specific URL content | URL Crawler (`crawl4ai__md`) | Try Context7 first for library docs |
| 5 | Last resort - search | WebSearch | ONLY after Perplexity Search/Ask exhausted |
| 6 | Last resort - fetch | WebFetch | ONLY after URL Crawler exhausted |

**CRITICAL: WebSearch and WebFetch are last resort tools:**
- WebSearch: Use ONLY when Perplexity Search AND Perplexity Ask both failed
- WebFetch: Use ONLY when URL Crawler failed OR user explicitly provides URL to fetch

## Critical Anti-Patterns

Learn these mistakes to avoid them:

❌ **Library docs → WebSearch or WebFetch**
- WRONG: Use WebSearch/WebFetch for Fish, Tmux, etc.
- RIGHT: Use Context7 MCP or Perplexity first
- Why: Context7/Perplexity provide structured, up-to-date docs

❌ **"ask about X" → WebFetch**
- WRONG: Fetch docs when user says "ask about" or "tell me about"
- RIGHT: Answer from training knowledge (not a URL fetch request)
- Why: WebFetch is ONLY for explicit URLs provided by user

## Key Decision Rules

1. **Tool/library docs?** → Context7 MCP or Perplexity Search
2. **Known URL?** → Try Context7 first (if library), else URL Crawler → WebFetch (last resort)
3. **Generic search?** → Perplexity Search → Perplexity Ask → WebSearch (last resort)
4. **User says "crawl [url]"?** → URL Crawler → WebFetch (if failed)
5. **User says "search [query]"?** → Perplexity Search → Perplexity Ask → WebSearch (if failed)
6. **User provides explicit URL?** → URL Crawler → WebFetch (fallback)

## Context7 MCP Quick Reference

**Token limits (always specify):**
- Focused: `tokens: 3000`
- Default: `tokens: 5000`
- Broad: `tokens: 8000`
- Maximum: `tokens: 10000`

**Always provide `topic` parameter** (e.g., "functions", "configuration", "plugins")

**Examples:**
- Fish shell functions → Context7, topic: "functions", tokens: 5000
- Tmux configuration → Context7, topic: "configuration", tokens: 5000
- Fisher plugins → Context7, topic: "plugins", tokens: 3000

## Perplexity Tools

For detailed guidance on Perplexity Search, Ask, and Researcher agent, see the `perplexity` skill.

**Quick reference:**
- **Perplexity Search** - Find URLs/resources, always use `max_results: 3` and `max_tokens_per_page: 512`
- **Perplexity Ask** - Conversational answers when Search returns nothing
- **Researcher agent** - Deep multi-source research (use `/research <topic>`)
- **Never use** `perplexity_research` tool - use researcher agent instead

## Common Dotfiles Topics

### Fish Shell
- Functions and configuration
- Fisher package manager
- Custom completions
- Environment variables

### Testing
- Fishtape testing framework
- Writing `@test` blocks
- Test organization

### Git Worktrees
- Worktree management
- Integration with tmux
- Custom wt commands

### Tmux
- Configuration and keybindings
- Window/session management
- Integration with shell tools
