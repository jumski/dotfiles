# Neovim LSP: per-buffer **denols** vs **ts_ls** without conflicts

Works with Neovim **0.11+**. Uses `vim.lsp.config()` + `vim.lsp.enable()` and a `root_dir(buf, on_dir)` gate so each buffer picks the right server. ([Neovim][1])

---

## Why this solves the conflict

Neovim auto-starts LSP per buffer using `filetypes`, `root_markers`, and `root_dir`. The **function** form of `root_dir(buf, on_dir)` activates a server only if you call `on_dir(root)`. If you skip calling it, that server will not attach to that buffer. This cleanly prevents `ts_ls` from attaching inside Deno workspaces. ([Neovim][1])

---

## Requirements

- Neovim **0.11+**. API introduced in 0.11. ([Neovim][1])
- Deno CLI (the LSP is built in: `deno lsp`). ([Deno][2])
- TypeScript LS:

  ```bash
  npm i -g typescript-language-server typescript
  ```

  Runs as `typescript-language-server --stdio`. ([npm][3])

---

## Drop-in config

Put this in `init.lua` or `lua/lsp/deno_ts.lua` and `require` it.

```lua
-- Helpers
local function deno_root(bufnr)
  return vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
end

local function node_root(bufnr)
  return vim.fs.root(bufnr, { "package.json", "tsconfig.json", "jsconfig.json" })
end

-- Deno LSP: attach only inside Deno projects
vim.lsp.config("denols", {
  cmd = { "deno", "lsp" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    local root = deno_root(bufnr)
    if root then on_dir(root) end
  end,
  -- Deno LSP reads options via initialization/settings; enable is commonly used
  settings = { deno = { enable = true } },
})

-- TypeScript LS: refuse to attach where a Deno root exists
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    if deno_root(bufnr) then return end
    local root = node_root(bufnr)
    if root then on_dir(root) end
  end,
})

-- Enable both once; root_dir decides per buffer
vim.lsp.enable({ "denols", "ts_ls" })

-- Optional safety net: if both ever attach, keep denols
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local has_deno, ts_id
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
      if c.name == "denols" then has_deno = true end
      if c.name == "ts_ls" then ts_id = c.id end
    end
    if has_deno and ts_id then vim.lsp.stop_client(ts_id) end
  end,
})
```

`vim.lsp.config` defines configs. `vim.lsp.enable` auto-activates them based on `filetypes` and `root_dir`. The function gate is the official way to decide per-buffer activation. ([Neovim][1])

---

## How it works

- Opening a buffer under `.../deno_project/` with `deno.json` calls `on_dir(deno_root)` for `denols`; `ts_ls` is skipped.
- Opening a buffer under `.../node_project/` with `package.json|tsconfig.json` calls `on_dir(node_root)` for `ts_ls`.
- You can open one Deno buffer and one Node buffer at the same time. Each attaches its own client. Check with:

  ```vim
  :lua for _,c in ipairs(vim.lsp.get_clients({bufnr=0})) do print(c.name, c.root_dir) end
  ```

  Neovim resolves enablement using these fields and shows enabled configs in `:checkhealth vim.lsp`. ([Neovim][1])

---

## Verification steps

1. Open a file inside a Deno workspace. Expect `denols` only.
2. Open a file inside a Node workspace. Expect `ts_ls` only.
3. Run `:checkhealth vim.lsp` to confirm both configs are enabled. ([Neovim][1])

---

## Notes

- `vim.fs.root(buf, markers)` finds the nearest ancestor containing any of the given markers; available since 0.10. Use it for roots instead of custom `vim.fs.find` logic. ([Neovim][4])
- You can also express global fallbacks with `root_markers` on a config, but the **function form** of `root_dir` gives precise control and is the recommended pattern for conditional activation. ([Neovim][1])

---

## Uninstall / disable

Disable at runtime:

```vim
:lua vim.lsp.enable({ "denols", "ts_ls" }, false)
```

This stops and detaches matching clients. Re-enable with `true`. ([Neovim][1])

---

## Appendix: server binaries

- Deno LSP lives in the Deno CLI (`deno lsp`). No extra package. ([Deno][2])
- TypeScript LS install and run: `npm i -g typescript-language-server typescript` then `typescript-language-server --stdio`. ([npm][3])

---

[1]: https://neovim.io/doc/user/lsp.html " Lsp - Neovim docs"
[2]: https://docs.deno.com/runtime/reference/cli/lsp/?utm_source=chatgpt.com "deno lsp"
[3]: https://www.npmjs.com/package/typescript-language-server?utm_source=chatgpt.com "typescript-language-server"
[4]: https://neovim.io/doc/user/lua.html?utm_source=chatgpt.com "Lua - Neovim docs"
