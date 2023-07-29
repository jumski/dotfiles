function versioned_files
    # Check if argument is provided
    if test -z $argv
        echo "Please provide a path prefix"
        return 1
    end

    # Store the path prefix provided as an argument
    set prefix $argv[1]

    # Use 'find' with the path prefix and filter files matching '_vN.' in their name
    # find $prefix -type f -name '*_v*.*' 2>/dev/null | grep -E '_v[0-9]+\.'

    # If you don't want to use 'grep', you can use 'find' with regex directly
    find $prefix -type f -regex '.*_v[0-9]+\..*' 2>/dev/null
end
