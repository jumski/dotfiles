function smb-nas --description "Explore NAS via SMB"
    set -l creds /etc/samba/credentials/nas
    set -l host nas

    # Parse arguments
    set -l share ""
    set -l show_help false

    for arg in $argv
        switch $arg
            case -h --help
                set show_help true
            case '-*'
                echo "Unknown option: $arg" >&2
                return 1
            case '*'
                if test -z "$share"
                    set share $arg
                end
        end
    end

    if $show_help
        echo "Usage: smb-nas [SHARE]"
        echo ""
        echo "Explore NAS at '$host' using credentials from $creds"
        echo ""
        echo "Examples:"
        echo "  smb-nas           # List available shares"
        echo "  smb-nas media     # Browse 'media' share"
        echo "  smb-nas backup    # Browse 'backup' share"
        return 0
    end

    if not test -f $creds
        echo "Credentials file not found: $creds" >&2
        return 1
    end

    if test -z "$share"
        # List shares
        echo "Listing shares on $host..."
        smbclient -A $creds -L $host
    else
        # Connect to specific share
        echo "Connecting to //$host/$share..."
        smbclient -A $creds "//$host/$share"
    end
end
