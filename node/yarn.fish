# sup yarn
# https://yarnpkg.com

if which yarn &>/dev/null
  set -x PATH $PATH:(yarn global bin)
end
