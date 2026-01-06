function beads-pgflow-status --description "Show beads daemon status and recent logs"
    echo "=== Daemon Status ==="
    systemctl --user status beads-daemon.service --no-pager
    echo ""
    echo "=== Recent Logs (last 30 lines) ==="
    journalctl --user -u beads-daemon.service --no-pager -n 30
end
