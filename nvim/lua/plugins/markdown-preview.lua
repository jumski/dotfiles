return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    
    -- Add <leader>mm shortcut for MarkdownPreview
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>mm', ':MarkdownPreview<CR>', { noremap = true, silent = true })
      end,
    })
  end,
  ft = { "markdown" },
}
