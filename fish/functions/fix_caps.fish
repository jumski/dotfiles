function fix_caps
  # Check if Caps Lock is enabled by querying the LED state
  set -l caps_state (xset -q | grep "Caps Lock" | awk '{print $4}')

  # Only toggle Caps Lock if it's currently on
  if test "$caps_state" = "on"
    xdotool key Caps_Lock
    echo "Caps Lock disabled"
  else
    echo "Caps Lock is already off"
  end
end

alias FIX_CAPS=fix_caps
