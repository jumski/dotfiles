function vmw_ssh --description "SSH into a VMW VM"
    set -l vm_name $argv[1]

    if test -z "$vm_name"
        echo "Error: VM name required" >&2
        return 1
    end

    ssh -A claude@$vm_name.local
end
