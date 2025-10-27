#!/usr/bin/env fish
# Interactive tutorials for wt/gt workflow

function wt_tutor
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt tutor [topic]

Interactive tutorials for wt/gt workflow

Topics:
  clone          Cloning repositories with worktree structure
  hotfix         Creating urgent fixes on main branch
  update         Syncing all stacks after merging changes
  branch         Creating a new feature branch
  stack          Creating next branch in a stack
  commit         Committing with amend workflows
  fork-pr        Converting fork PR to origin branch for wt/gt
  workflow       Complete development workflow walkthrough

Run 'wt tutor' with no arguments to see the interactive menu."
    and return 0

    set -l topic $argv[1]

    if test -z "$topic"
        _wt_tutor_menu
        return
    end

    switch $topic
        case clone clone-repo
            _wt_tutor_clone
        case hotfix main-hotfix
            _wt_tutor_main_hotfix
        case update sync-all update-all
            _wt_tutor_update_all_stacks
        case branch new-branch
            _wt_tutor_new_branch
        case stack stack-branch next-branch
            _wt_tutor_stack_branch
        case commit amend commit-amend
            _wt_tutor_commit_amend
        case fork-pr fork pr-fork
            _wt_tutor_fork_pr
        case doctor fix troubleshoot
            _wt_tutor_doctor
        case workflow full-workflow
            _wt_tutor_full_workflow
        case list menu
            _wt_tutor_menu
        case '*'
            echo "Unknown tutorial topic: $topic"
            _wt_tutor_menu
            return 1
    end
end
