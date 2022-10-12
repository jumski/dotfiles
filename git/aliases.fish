
alias g=git

function gc --wraps "git commit"
  git commit $argv
end

function gb --wraps "git branch -vv"
  git branch -vv $argv
end

function gs --wraps "git status -sb"
  git status -sb $argv
end

function gap --wraps "git add --patch"
  git add --intent-to-add . && git add --patch $argv
end

function gcob
  set branch (git-branch-fzf --sort=-committerdate)
  git checkout $branch
end

function gcoba
  set branch (git-branch-fzf --sort=-committerdate --all)
  git checkout $branch
end

alias gbf=git-branch-fzf

function gd --wraps "git diff"
  git diff --color $argv | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r
end

function gwip
  git add -A
  git rm (git ls-files --deleted) 2> /dev/null
  git commit --no-verify -m "--wip-- [skip ci]"
end

function gunwip
  git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1
end

# The rest of my fun git aliases
#alias gl='git pull --prune'
#alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
#alias gp='git push origin HEAD'
#
## Remove `+` and `-` from start of diff lines; just rely upon color.
#
# alias gca='git commit -a'
# alias gco='git checkout'
# alias gcb='git copy-branch-name'
## alias gbb='git branch -vv'
#alias gac='git add -A && git commit -m'
#alias ge='git-edit-new'
#
#alias gdiff='git diff --color-words=.'
