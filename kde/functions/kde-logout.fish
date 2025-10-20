function kde-logout -d "Log out of KDE session"
    echo "Logging out of KDE session..."
    qdbus org.kde.Shutdown /Shutdown logout
end
