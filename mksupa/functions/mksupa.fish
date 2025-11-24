function mksupa -d "Manage temporary Supabase projects"
    # Source lib functions
    set -l lib_dir (dirname (status --current-filename))/../lib
    source "$lib_dir/git.fish"
    source "$lib_dir/new_temp.fish"
    source "$lib_dir/init.fish"

    # Show help if no arguments or --help
    if test (count $argv) -eq 0; or test "$argv[1]" = "--help"
        echo "Usage: mksupa new <prefix> [--supabase=VERSION] [--pgflow=VERSION]"
        echo "       mksupa --init [--supabase=VERSION]"
        echo "       mksupa --help"
        echo ""
        echo "Commands:"
        echo "  new <prefix>  Create new temporary Supabase project"
        echo "  --init        Initialize Supabase in current directory"
        echo "  --help        Show this help message"
        echo ""
        echo "Options:"
        echo "  --supabase=VERSION  Use specific Supabase CLI version (default: 2.50.3)"
        echo "  --pgflow=VERSION    Create PGFLOW.md with specified version"
        return 0
    end

    set -l subcommand $argv[1]

    # Handle --init subcommand
    if test "$subcommand" = "--init"
        set -l supabase_version ""

        # Parse options for --init
        for arg in $argv[2..-1]
            if string match -q -- "--supabase=*" $arg
                set supabase_version (string replace -- "--supabase=" "" $arg)
            end
        end

        __mksupa_init $supabase_version
        return $status
    end

    # Handle 'new' subcommand
    if test "$subcommand" = "new"
        set -l prefix ""
        set -l supabase_version ""
        set -l pgflow_version ""

        # Parse arguments for 'new'
        for arg in $argv[2..-1]
            if string match -q -- "--supabase=*" $arg
                set supabase_version (string replace -- "--supabase=" "" $arg)
            else if string match -q -- "--pgflow=*" $arg
                set pgflow_version (string replace -- "--pgflow=" "" $arg)
            else
                set prefix $arg
            end
        end

        # Validate prefix is provided
        if test -z "$prefix"
            echo "Error: prefix is required"
            echo "Usage: mksupa new <prefix> [--supabase=VERSION] [--pgflow=VERSION]"
            return 1
        end

        __mksupa_new_temp $prefix $supabase_version $pgflow_version
        return $status
    end

    # Invalid subcommand
    echo "Error: unknown command '$subcommand'"
    echo "Usage: mksupa new <prefix> [--supabase=VERSION] [--pgflow=VERSION]"
    echo "       mksupa --init [--supabase=VERSION]"
    echo "       mksupa --help"
    return 1
end
