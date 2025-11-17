function restart_audio_server
  systemctl --user restart pipewire pipewire-pulse wireplumber
end
