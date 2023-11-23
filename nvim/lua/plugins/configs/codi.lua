-- vim.g.codi_interpreters = {
--   ruby = {
--     bin = {"docker-compose", "run", "web", "bin/rails", "console"},
--     prompt = '^\\[[0-9]+\\] pry\\((.*)\\)> '
--   }
-- }




vim.cmd([[
let g:codi#interpreters = {
      \ 'ruby': {
          \ 'bin': ["docker-compose", "--file", "/home/jumski/Code/todd/toolchest-rails/docker-compose.yml", "run", "web", "bin/rails", "console"],
          \ 'prompt': '/^\\[[0-9]+\\] pry\\((.*)\\)> /',
          \ },
      \ }
]])
          -- \ 'prompt': '^\\[[0-9]+\\] pry\\((.*)\\)> ',
