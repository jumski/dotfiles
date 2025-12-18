function vmw_check_deps --description "Check if required host dependencies are installed"
    set -l required_deps virsh qemu-img virtiofsd genisoimage
    set -l missing

    for dep in $required_deps
        if not which $dep >/dev/null 2>&1
            set -a missing $dep
        end
    end

    if test (count $missing) -gt 0
        echo "Missing: $missing" >&2
        return 1
    end

    return 0
end
