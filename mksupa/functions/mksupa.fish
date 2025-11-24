function mksupa -d "Manage temporary Supabase projects"
    # Source lib functions
    set -l lib_dir (dirname (status --current-filename))/../lib
    source "$lib_dir/git.fish"
    source "$lib_dir/new_temp.fish"
    source "$lib_dir/init.fish"

    # Route to appropriate mode
    if test (count $argv) -eq 0
        echo "Usage: mksupa <prefix> [--supabase=VERSION] [--pgflow=VERSION]"
        echo "       mksupa --init [--supabase=VERSION]"
        return 1
    end

    # Parse arguments
    set -l prefix ""
    set -l supabase_version ""
    set -l pgflow_version ""
    set -l is_init 0

    for arg in $argv
        if test "$arg" = "--init"
            set is_init 1
        else if string match -q -- "--supabase=*" $arg
            set supabase_version (string replace -- "--supabase=" "" $arg)
        else if string match -q -- "--pgflow=*" $arg
            set pgflow_version (string replace -- "--pgflow=" "" $arg)
        else
            set prefix $arg
        end
    end

    if test $is_init -eq 1
        __mksupa_init $supabase_version
    else
        # Validate prefix is provided
        if test -z "$prefix"
            echo "Error: prefix is required when creating a new project"
            echo "Usage: mksupa <prefix> [--supabase=VERSION] [--pgflow=VERSION]"
            return 1
        end
        __mksupa_new_temp $prefix $supabase_version $pgflow_version
    end
end
