-- Qargs provides functionality to populate the :args list with files from the quickfix list
-- This allows you to run commands on all files in the quickfix results using :argdo
-- Usage: Run :Qargs after populating the quickfix list to set up the args list
-- Then use :argdo to run commands on all those files

local M = {}

function M.get_quickfix_filenames()
  local buffer_numbers = {}
  local qf_list = vim.fn.getqflist()

  for _, item in ipairs(qf_list) do
    local bufname = vim.fn.bufname(item.bufnr)
    if bufname and bufname ~= "" then
      buffer_numbers[item.bufnr] = bufname
    end
  end

  local filenames = {}
  for _, fname in pairs(buffer_numbers) do
    table.insert(filenames, vim.fn.fnameescape(fname))
  end

  return table.concat(filenames, " ")
end

-- Create the command that uses the function
vim.api.nvim_create_user_command("Qargs", function()
  local files = M.get_quickfix_filenames()
  vim.cmd("args " .. files)
end, { bang = true })

return M
