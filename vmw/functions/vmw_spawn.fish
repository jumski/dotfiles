function vmw_spawn --description "Spawn a VM with read-only ~/Code and optional writable paths"
    # Handle --help / -h
    if contains -- --help $argv; or contains -- -h $argv; or test (count $argv) -lt 1
        echo "Usage: vmw spawn <vm-name> [writable-path...]" >&2
        echo "" >&2
        echo "Examples:" >&2
        echo "  vmw spawn dev-vm                           # read-only ~/Code" >&2
        echo "  vmw spawn dev-vm ~/Code/myproject          # myproject is writable" >&2
        echo "  vmw spawn dev-vm .                         # current dir is writable" >&2
        echo "  vmw spawn dev-vm ~/Code/proj1 ~/Code/proj2 # multiple writable" >&2
        return 1
    end

    set -l vm_name $argv[1]
    set -l raw_writable_paths $argv[2..-1]

    # Set defaults if not defined
    set -q VMW_CONFIG_DIR; or set -l VMW_CONFIG_DIR ~/.config/vmw
    set -l golden_image $VMW_CONFIG_DIR/golden-image.qcow2
    set -l instances_dir $VMW_CONFIG_DIR/instances
    set -l code_dir ~/Code

    # Validate golden image exists
    if not test -f "$golden_image"
        echo "Error: golden image not found at $golden_image" >&2
        echo "Run 'vmw setup' first to create the golden image" >&2
        return 1
    end

    # Validate ~/Code exists
    if not test -d "$code_dir"
        echo "Error: Code directory not found at $code_dir" >&2
        return 1
    end

    # Process writable paths: expand "." and resolve to absolute paths
    set -l writable_paths
    for raw_path in $raw_writable_paths
        set -l resolved_path
        if test "$raw_path" = "."
            set resolved_path $PWD
        else
            set resolved_path (realpath -m "$raw_path" 2>/dev/null; or echo "$raw_path")
        end

        # Expand ~ to home directory
        set resolved_path (string replace -r '^~' $HOME $resolved_path)

        # Validate path is under ~/Code
        if not string match -q "$code_dir/*" "$resolved_path"
            echo "Error: Writable path must be under ~/Code: $resolved_path" >&2
            return 1
        end

        # Auto-create if doesn't exist
        if not test -d "$resolved_path"
            echo "Creating directory: $resolved_path"
            mkdir -p "$resolved_path"
        end

        set -a writable_paths $resolved_path
    end

    # Create instance directory
    set -l instance_dir $instances_dir/$vm_name
    mkdir -p $instance_dir

    set -l disk_path $instance_dir/disk.qcow2
    set -l cloudinit_iso $instance_dir/cloud-init.iso
    set -l domain_xml $instance_dir/domain.xml
    set -l host_dir $VMW_CONFIG_DIR/guest

    echo "Spawning VM: $vm_name"
    echo "Code directory: $code_dir (read-only)"
    if test (count $writable_paths) -gt 0
        echo "Writable paths:"
        for wp in $writable_paths
            echo "  - $wp"
        end
    end

    # Create linked clone from golden image
    if not test -f $disk_path
        echo "Creating linked clone..."
        qemu-img create -f qcow2 -F qcow2 -b $golden_image $disk_path
        if test $status -ne 0
            echo "Error: Failed to create disk clone" >&2
            return 1
        end
    end

    # Stage ~/.claude/ for mounting
    echo "Staging ~/.claude/ for mount..."
    set -l claude_staging_dir $instance_dir/claude-staging
    rm -rf $claude_staging_dir
    _vmw_stage_claude $claude_staging_dir
    if test $status -ne 0
        echo "Error: Failed to stage claude directory" >&2
        return 1
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

    # Generate writable paths list for cloud-init (relative paths under /home/jumski/Code)
    set -l writable_paths_list ""
    for wp in $writable_paths
        set -l relative_path (string replace "$code_dir/" "" "$wp")
        set writable_paths_list "$writable_paths_list$relative_path\n"
    end

    # Generate claude mount items list (space-separated) from claude-mount.list
    set -l claude_mount_items ""
    set -l claude_mount_list (dirname (status filename))/../claude-mount.list
    if test -f "$claude_mount_list"
        for line in (cat "$claude_mount_list")
            set -l trimmed (string trim $line)
            if test -n "$trimmed"; and not string match -q '#*' $trimmed
                set claude_mount_items "$claude_mount_items$trimmed "
            end
        end
    end

    # user-data
    sed -e "s|{{VM_NAME}}|$vm_name|g" \
        -e "s|{{SSH_PUBLIC_KEY}}|$ssh_key|g" \
        -e "s|{{WRITABLE_PATHS}}|$writable_paths_list|g" \
        -e "s|{{CLAUDE_MOUNT_ITEMS}}|$claude_mount_items|g" \
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
    echo "Starting virtiofsd daemons..."
    set -l virtiofsd_bin (_vmw_virtiofsd_path)

    # Socket paths
    set -l code_socket $instance_dir/virtiofsd-code.sock
    set -l host_socket $instance_dir/virtiofsd-host.sock
    set -l claude_socket $instance_dir/virtiofsd-claude.sock
    set -l dotfiles_claude_socket $instance_dir/virtiofsd-dotfiles-claude.sock

    # Kill any existing virtiofsd for this VM
    pkill -f "virtiofsd.*$instance_dir" 2>/dev/null

    # Start virtiofsd for ~/Code (ro enforced at mount level in VM)
    $virtiofsd_bin --socket-path=$code_socket \
        --shared-dir=$code_dir \
        --cache=auto &

    # Start virtiofsd for ~/host (guest files: secrets.env, functions.sh)
    $virtiofsd_bin --socket-path=$host_socket \
        --shared-dir=$host_dir \
        --cache=auto &

    # Start virtiofsd for claude config
    $virtiofsd_bin --socket-path=$claude_socket \
        --shared-dir=$claude_staging_dir \
        --cache=auto &

    # Start virtiofsd for ~/.dotfiles/claude/ (symlink target for ~/.claude/ items)
    set -l dotfiles_claude_dir ~/.dotfiles/claude
    $virtiofsd_bin --socket-path=$dotfiles_claude_socket \
        --shared-dir=$dotfiles_claude_dir \
        --cache=auto &

    # Start virtiofsd for each writable path
    set -l rw_sockets
    set -l rw_index 0
    for wp in $writable_paths
        set -l rw_socket $instance_dir/virtiofsd-rw-$rw_index.sock
        set -a rw_sockets $rw_socket
        $virtiofsd_bin --socket-path=$rw_socket \
            --shared-dir=$wp \
            --cache=auto &
        set rw_index (math $rw_index + 1)
    end

    # Wait for sockets to be created
    sleep 1

    # Generate domain XML
    echo "Generating libvirt domain XML..."
    set -l bridge_name "br0"

    # Build writable filesystem entries for domain.xml
    set -l rw_filesystem_entries ""
    set rw_index 0
    for rw_socket in $rw_sockets
        set -l relative_path (string replace "$code_dir/" "" "$writable_paths[$rw_index + 1]")
        set rw_filesystem_entries "$rw_filesystem_entries
    <!-- Virtiofs: writable path $relative_path -->
    <filesystem type='mount' accessmode='passthrough'>
      <driver type='virtiofs'/>
      <source socket='$rw_socket'/>
      <target dir='rw_$rw_index'/>
    </filesystem>"
        set rw_index (math $rw_index + 1)
    end

    # Read template and substitute variables
    sed -e "s|{{VM_NAME}}|$vm_name|g" \
        -e "s|{{DISK_PATH}}|$disk_path|g" \
        -e "s|{{CLOUDINIT_ISO}}|$cloudinit_iso|g" \
        -e "s|{{VIRTIOFS_CODE_SOCKET}}|$code_socket|g" \
        -e "s|{{VIRTIOFS_HOST_SOCKET}}|$host_socket|g" \
        -e "s|{{VIRTIOFS_CLAUDE_SOCKET}}|$claude_socket|g" \
        -e "s|{{VIRTIOFS_DOTFILES_CLAUDE_SOCKET}}|$dotfiles_claude_socket|g" \
        -e "s|{{BRIDGE_NAME}}|$bridge_name|g" \
        -e "s|{{RW_FILESYSTEM_ENTRIES}}|$rw_filesystem_entries|g" \
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
    echo "Or manually: ssh -A jumski@$vm_name.local"
end
