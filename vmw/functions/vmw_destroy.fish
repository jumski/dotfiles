function vmw_destroy --description "Destroy a VMW VM"
    set -l vm_name $argv[1]

    if test -z "$vm_name"
        echo "Error: VM name required" >&2
        return 1
    end

    # Force stop the VM if running
    virsh destroy $vm_name 2>/dev/null

    # Remove the VM definition
    virsh undefine $vm_name
end
