function _vmw_virtiofsd_exists --description "Check if virtiofsd is available"
    which virtiofsd >/dev/null 2>&1; or test -x /usr/lib/virtiofsd
end

function _vmw_virtiofsd_path --description "Return the path to virtiofsd binary"
    if which virtiofsd >/dev/null 2>&1
        which virtiofsd
    else if test -x /usr/lib/virtiofsd
        echo /usr/lib/virtiofsd
    else
        return 1
    end
end

function vmw_check_deps --description "Check if required host dependencies are installed"
    set -l required_deps virsh qemu-img qemu-system-x86_64 genisoimage
    set -l missing

    for dep in $required_deps
        if not which $dep >/dev/null 2>&1
            set -a missing $dep
        end
    end

    # virtiofsd is installed at /usr/lib/virtiofsd on Arch/Manjaro
    if not _vmw_virtiofsd_exists
        set -a missing virtiofsd
    end

    if test (count $missing) -gt 0
        echo "Missing: $missing" >&2
        return 1
    end

    return 0
end
