function _vmw_virtiofsd_path --description "Return the path to virtiofsd binary"
    if which virtiofsd >/dev/null 2>&1
        which virtiofsd
    else if test -x /usr/lib/virtiofsd
        echo /usr/lib/virtiofsd
    else
        return 1
    end
end
