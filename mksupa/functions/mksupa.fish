function mksupa -d "Manage temporary Supabase projects"
    # Source lib functions
    set -l lib_dir (dirname (status --current-filename))/../lib
    source "$lib_dir/git.fish"
    source "$lib_dir/new_temp.fish"
    source "$lib_dir/init.fish"

    # Route to appropriate mode
    if test (count $argv) -eq 0
        echo "Usage: mksupa <prefix>  - Create new temp Supabase project"
        echo "       mksupa --init    - Initialize Supabase in current directory"
        return 1
    end

    if test "$argv[1]" = "--init"
        __mksupa_init
    else
        __mksupa_new_temp $argv[1]
    end
end
