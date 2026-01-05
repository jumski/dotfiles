function vmw_spawn --description "Spawn a VM for a worktree"
    set -l worktree_path $argv[1]

    # Set defaults if not defined
    set -q VMW_CONFIG_DIR; or set -l VMW_CONFIG_DIR ~/.config/vmw
    set -l golden_image $VMW_CONFIG_DIR/golden-image.qcow2
    set -l instances_dir $VMW_CONFIG_DIR/instances

    # Validate path
    if test -z "$worktree_path"
        echo "Error: Worktree path is required" >&2
        return 1
    end

    if not test -d "$worktree_path"
        echo "Error: Path does not exist: $worktree_path" >&2
        return 1
    end

    # Validate golden image exists
    if not test -f "$golden_image"
        echo "Error: golden image not found at $golden_image" >&2
        echo "Run 'vmw setup' first to create the golden image" >&2
        return 1
    end

    # Extract VM name from path
    set -l vm_name (vmw_extract_name "$worktree_path")
    if test $status -ne 0
        echo "Error: Could not extract VM name from path" >&2
        return 1
    end

    # Create instance directory
    set -l instance_dir $instances_dir/$vm_name
    mkdir -p $instance_dir

    set -l disk_path $instance_dir/disk.qcow2
    set -l cloudinit_iso $instance_dir/cloud-init.iso
    set -l domain_xml $instance_dir/domain.xml
    set -l secrets_dir $VMW_CONFIG_DIR

    echo "Spawning VM: $vm_name"
    echo "Worktree: $worktree_path"

    # Create linked clone from golden image
    if not test -f $disk_path
        echo "Creating linked clone..."
        qemu-img create -f qcow2 -F qcow2 -b $golden_image $disk_path
        if test $status -ne 0
            echo "Error: Failed to create disk clone" >&2
            return 1
        end
    end

    # Generate cloud-init ISO
    echo "Generating cloud-init ISO..."
    set -l cloudinit_dir $instance_dir/cloud-init
    mkdir -p $cloudinit_dir

    # Get SSH public key
    set -l ssh_key ""
    if test -f ~/.ssh/id_ed25519.pub
        set ssh_key (cat ~/.ssh/id_ed25519.pub)
    else if test -f ~/.ssh/id_rsa.pub
        set ssh_key (cat ~/.ssh/id_rsa.pub)
    else
        echo "Warning: No SSH public key found" >&2
    end

    # Generate cloud-init files from templates
    set -l template_dir (dirname (status filename))/../templates

    # meta-data
    sed -e "s|{{VM_NAME}}|$vm_name|g" \
        $template_dir/cloud-init/meta-data.template > $cloudinit_dir/meta-data

    # network-config (uses driver matching for interface name flexibility)
    cp $template_dir/cloud-init/network-config.template $cloudinit_dir/network-config

    # user-data (includes avahi-daemon for mDNS)
    sed -e "s|{{VM_NAME}}|$vm_name|g" \
        -e "s|{{SSH_PUBLIC_KEY}}|$ssh_key|g" \
        $template_dir/cloud-init/user-data.template > $cloudinit_dir/user-data

    # Create ISO
    genisoimage -output $cloudinit_iso -volid cidata -joliet -rock \
        $cloudinit_dir/user-data $cloudinit_dir/meta-data \
        $cloudinit_dir/network-config 2>/dev/null
    if test $status -ne 0
        echo "Error: Failed to create cloud-init ISO" >&2
        return 1
    end

    # Start virtiofsd instances
    echo "Starting virtiofsd for worktree..."
    set -l repo_socket $instance_dir/virtiofsd-repo.sock
    set -l secrets_socket $instance_dir/virtiofsd-secrets.sock
    set -l virtiofsd_bin (_vmw_virtiofsd_path)

    # Kill any existing virtiofsd for this VM
    pkill -f "virtiofsd.*$repo_socket" 2>/dev/null
    pkill -f "virtiofsd.*$secrets_socket" 2>/dev/null

    # Start virtiofsd for repo (writable)
    $virtiofsd_bin --socket-path=$repo_socket \
        --shared-dir=$worktree_path \
        --cache=auto &
    set -l repo_pid $last_pid

    # Start virtiofsd for secrets (read-only would be ideal but virtiofsd doesn't support it directly)
    $virtiofsd_bin --socket-path=$secrets_socket \
        --shared-dir=$secrets_dir \
        --cache=auto &
    set -l secrets_pid $last_pid

    # Wait for sockets to be created
    sleep 1

    # Generate domain XML
    echo "Generating libvirt domain XML..."
    set -l bridge_name "br0"  # Bridge to physical network for mDNS

    # Read template and substitute variables
    sed -e "s|{{VM_NAME}}|$vm_name|g" \
        -e "s|{{DISK_PATH}}|$disk_path|g" \
        -e "s|{{CLOUDINIT_ISO}}|$cloudinit_iso|g" \
        -e "s|{{VIRTIOFS_REPO_SOCKET}}|$repo_socket|g" \
        -e "s|{{VIRTIOFS_SECRETS_SOCKET}}|$secrets_socket|g" \
        -e "s|{{BRIDGE_NAME}}|$bridge_name|g" \
        $template_dir/domain.xml.template > $domain_xml

    # Define and start VM
    echo "Starting VM..."
    virsh define $domain_xml
    if test $status -ne 0
        echo "Error: Failed to define VM" >&2
        return 1
    end

    virsh start $vm_name
    if test $status -ne 0
        echo "Error: Failed to start VM" >&2
        return 1
    end

    echo ""
    echo "VM '$vm_name' started successfully!"
    echo "Wait for mDNS, then connect with: vmw ssh $vm_name"
    echo "Or manually: ssh -A claude@$vm_name.local"
end
