---
name: reading-websites
description: Use when you need to read, fetch, or view content from a URL or website - provides a secure wrapper script that returns website content as text without requiring broad curl permissions
---

# Reading Websites

## Overview

**Use `fetch-url.sh` to read website content.** This wrapper script is the ONLY approved method for fetching URLs.

## When to Use

- User asks you to read/fetch/check a URL
- You need to see what's on a webpage
- Documentation, articles, or web content needs to be retrieved

## The Command

```bash
~/.claude/skills/reading-websites/fetch-url.sh <url> [char_limit]
```

**Arguments:**
- `url` - Full URL with protocol (e.g., `https://example.com/page`)
- `char_limit` - Optional. Max characters to return (default: 512)

**Examples:**
```bash
# Read first 512 chars (default)
~/.claude/skills/reading-websites/fetch-url.sh https://docs.example.com/api

# Read more content
~/.claude/skills/reading-websites/fetch-url.sh https://docs.example.com/api 2000
```

## Why This Wrapper

**Security:** This script has explicit permission. Raw `curl` does not.

**Do NOT use:**
- `curl` directly
- `WebFetch` tool
- `mcp__crawl4ai` tools
- Any other URL fetching method

**Why:** The wrapper is permissioned and scoped. Other methods require broad permissions that expose security risks.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using curl directly | Use fetch-url.sh |
| Using WebFetch "because it's faster" | Use fetch-url.sh |
| Using crawl4ai "because it's better" | Use fetch-url.sh |
| Forgetting the protocol | Include `https://` in URL |

## Red Flags - You're About to Violate This Skill

- "curl is simpler for this"
- "WebFetch is already available"
- "crawl4ai returns cleaner output"
- "This is just a quick fetch"
- "The wrapper is overkill for this"

**All of these mean: Use fetch-url.sh anyway.**
