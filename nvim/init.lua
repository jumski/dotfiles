require("core.envs")
require("core.settings")
require("core.clipboard")
require("core.mappings")
require("core.qargs")

local python_version = io.popen("which python3"):read()
vim.g.python3_host_prog = string.gsub(python_version, "\n", "")

require("core.plugins")
