function kwin-reconfigure -d "Reconfigure KWin to apply configuration changes"
    echo "Restarting KWin..."
    qdbus org.kde.KWin /KWin reconfigure
    echo "Done! KWin has been reconfigured."
end
