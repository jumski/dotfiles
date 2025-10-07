# LSP Configuration Issue: denols vs ts_ls Conflict

## Problem

When opening a TypeScript file in a nested project structure where:
- Parent directory contains `package.json` (Node.js project)
- Subdirectory contains `deno.json` (Deno project)

**Expected behavior:** `denols` should start for files in the Deno subdirectory

**Actual behavior:** `ts_ls` starts instead, because it's enabled globally and finds the parent `package.json`

## Root Cause

Using `vim.lsp.enable("ts_ls")` without a buffer argument enables the LSP globally for all TypeScript/JavaScript files. When a file is opened, Neovim searches upward from the file's directory for root markers (`package.json`, `tsconfig.json`) and will start `ts_ls` even if a closer `deno.json` exists in a subdirectory.

## Solution Approach

1. **Remove global LSP enabling**: Don't call `vim.lsp.enable()` without a buffer for either `ts_ls` or `denols`

2. **Use autocommands with conditional logic**: On `BufReadPost` and `BufNewFile` for TypeScript/JavaScript files:
   - First check for Deno root markers (`deno.json`, `deno.jsonc`) using `vim.lsp.util.root_pattern()`
   - If Deno markers found → enable `denols` for that buffer only
   - Otherwise check for Node.js markers (`package.json`, `tsconfig.json`)
   - If Node.js markers found → enable `ts_ls` for that buffer only

3. **Prioritize denols**: When both marker types exist in the directory tree, prefer `denols` by checking for Deno markers first

4. **Stop conflicting LSP**: Before enabling the chosen LSP, stop the other one if it's already running on that buffer

## Key Neovim LSP API

- `vim.lsp.config(name, config)` - Configure LSP with `root_markers`
- `vim.lsp.enable(name, bufnr)` - Enable LSP for specific buffer (or globally if `bufnr` omitted)
- `vim.lsp.get_clients({ bufnr = ..., name = ... })` - Get running clients
- `vim.lsp.util.root_pattern(...)` - Create function to find project root
- `vim.lsp.stop_client(client_id)` - Stop specific LSP client

## Related Issues

- Neovim LSP client conflict when multiple LSPs can handle same filetype
- Per-buffer LSP activation vs global activation
- Monorepo with mixed Deno/Node.js projects
