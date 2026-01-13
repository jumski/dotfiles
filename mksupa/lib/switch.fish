function __mksupa_switch
    set -l selected_path (__mksupa_path)

    if test -z "$selected_path"
        return 0
    end

    muxit "$selected_path"
end
