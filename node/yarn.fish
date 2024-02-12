# sup yarn
# https://yarnpkg.com

if which yarn &>/dev/null
  set yarn_global_path (yarn global bin)
  set -x PATH "$PATH:$yarn_global_path"
end
