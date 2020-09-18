# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
if which hub &>/dev/null
  alias git=hub
end

alias g=git


# The rest of my fun git aliases
#alias gl='git pull --prune'
#alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
#alias gp='git push origin HEAD'
#
## Remove `+` and `-` from start of diff lines; just rely upon color.
alias gd='git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r'
#
alias gc='git commit'
# alias gca='git commit -a'
# alias gco='git checkout'
# alias gcb='git copy-branch-name'
alias gb='git branch -vv'
## alias gbb='git branch -vv'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
#alias gac='git add -A && git commit -m'
#alias ge='git-edit-new'
#
#alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'
#alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
#
#alias gdiff='git diff --color-words=.'
#compdef _git gdiff='git-diff'
#
alias gapan='git add --intent-to-add . && git add --patch'
alias gap='git add --intent-to-add . && git add --patch'
#compdef _git gapan='git-add'
#compdef _git gap='git-add'
#
alias gcob='git checkout (git-branch-fzf --sort=-committerdate)'
alias gcoba='git checkout (git-branch-fzf --sort=-committerdate --all)'
alias gbf=git-branch-fzf
