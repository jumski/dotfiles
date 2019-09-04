
if which yarn 2>&1 >/dev/null; then
  export PATH=$(yarn global bin):$PATH
fi
