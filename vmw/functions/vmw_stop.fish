function vmw_stop --description "Stop a VMW VM"
    set -l vm_name $argv[1]

    if test -z "$vm_name"
        echo "Error: VM name required" >&2
        return 1
    end

    virsh shutdown $vm_name
end
