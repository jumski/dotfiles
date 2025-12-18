function vmw_setup --description "One-time setup for VMW"
    # Set defaults if not defined
    set -q VMW_CONFIG_DIR; or set -l VMW_CONFIG_DIR ~/.config/vmw
    set -l golden_image $VMW_CONFIG_DIR/golden-image.qcow2
    set -l instances_dir $VMW_CONFIG_DIR/instances
    set -l secrets_file $VMW_CONFIG_DIR/secrets.env

    # Debian 12 cloud image URL
    set -l debian_image_url "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"

    echo "VMW Setup - Creating golden image and config"
    echo "============================================="

    # Check dependencies
    echo "Checking dependencies..."
    if not vmw_check_deps
        echo "Please install missing dependencies first" >&2
        return 1
    end
    echo "All dependencies available"

    # Create directories
    echo "Creating config directories..."
    mkdir -p $VMW_CONFIG_DIR
    mkdir -p $instances_dir

    # Create secrets file if not exists
    if not test -f $secrets_file
        echo "Creating secrets.env template..."
        echo "# VMW secrets - API keys for VMs" > $secrets_file
        echo "# ANTHROPIC_API_KEY=sk-ant-xxx" >> $secrets_file
        echo "# PERPLEXITY_API_KEY=xxx" >> $secrets_file
        chmod 600 $secrets_file
        echo "Edit $secrets_file to add your API keys"
    end

    # Download Debian cloud image if not exists
    if not test -f $golden_image
        echo "Downloading Debian 12 cloud image..."
        wget -O $golden_image $debian_image_url
        if test $status -ne 0
            echo "Failed to download Debian image" >&2
            return 1
        end

        # Resize to 20GB
        echo "Resizing image to 20GB..."
        qemu-img resize $golden_image 20G
    else
        echo "Golden image already exists at $golden_image"
    end

    echo ""
    echo "Setup complete!"
    echo "Next steps:"
    echo "  1. Edit $secrets_file with your API keys"
    echo "  2. Run: vmw spawn /path/to/worktree"
end
