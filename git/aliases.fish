

# The rest of my fun git aliases
#alias gl='git pull --prune'
#alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
#alias gp='git push origin HEAD'
#
## Remove `+` and `-` from start of diff lines; just rely upon color.
alias gd='git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r'
#
# alias gca='git commit -a'
# alias gco='git checkout'
# alias gcb='git copy-branch-name'
## alias gbb='git branch -vv'
#alias gac='git add -A && git commit -m'
#alias ge='git-edit-new'
#
#alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'
#alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
#
#alias gdiff='git diff --color-words=.'
#compdef _git gdiff='git-diff'
#
#compdef _git gapan='git-add'
#compdef _git gap='git-add'
#
