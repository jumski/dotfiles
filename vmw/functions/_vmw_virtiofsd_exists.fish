function _vmw_virtiofsd_exists --description "Check if virtiofsd is available"
    which virtiofsd >/dev/null 2>&1; or test -x /usr/lib/virtiofsd
end
