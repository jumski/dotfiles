# shellcheck shell=bash
# Default Theme
# If changes made here does not take effect, then try to re-create the tmux session to force reload.

# Hostname-based color schemes
HOSTNAME=$(hostname)
if [ "$HOSTNAME" = "laptop" ]; then
	# Laptop theme: terminal bg, cyan accents
	TMUX_POWERLINE_DEFAULT_BG="terminal"
	TMUX_POWERLINE_DEFAULT_FG="109"
	TMUX_POWERLINE_ACCENT="109"
	TMUX_POWERLINE_SESSION_ACCENT="109"
	TMUX_POWERLINE_TIME_ACCENT="116"
else
	# PC theme: terminal bg, purple accents
	TMUX_POWERLINE_DEFAULT_BG="terminal"
	TMUX_POWERLINE_DEFAULT_FG="141"
	TMUX_POWERLINE_ACCENT="141"
	TMUX_POWERLINE_SESSION_ACCENT="141"
	TMUX_POWERLINE_TIME_ACCENT="146"
fi

if tp_patched_font_in_use; then
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
else
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
fi

# See Color formatting section below for details on what colors can be used here.
# Set hostname-based theme colors
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-$TMUX_POWERLINE_DEFAULT_BG}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-$TMUX_POWERLINE_DEFAULT_FG}
# shellcheck disable=SC2034
TMUX_POWERLINE_SEG_AIR_COLOR=$(tp_air_color)

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}

# See `man tmux` for additional formatting options for the status line.
# The `format regular` and `format inverse` functions are provided as conveniences

# shellcheck disable=SC2128
# Current window: [accent #I:#W]
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
		"#[fg=terminal,bg=colour${TMUX_POWERLINE_ACCENT}]◤"
		"#[fg=colour232,bg=colour${TMUX_POWERLINE_ACCENT},bold]#I#F #{=12:window_name}"
	)
fi

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_STYLE" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_STYLE=(
		"#[fg=colour${TMUX_POWERLINE_TIME_ACCENT},bg=terminal]"
	)
fi

# shellcheck disable=SC2128
# Regular window: [terminal #I:#W]
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_FORMAT" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
		"#[fg=colour${TMUX_POWERLINE_ACCENT},bg=terminal]#I#F #{=12:window_name}"
	)
fi

# Format: segment_name [background_color|default_bg_color] [foreground_color|default_fg_color] [non_default_separator|default_separator] [separator_background_color|no_sep_bg_color]
#                      [separator_foreground_color|no_sep_fg_color] [spacing_disable|no_spacing_disable] [separator_disable|no_separator_disable]
#
# * background_color and foreground_color. Color formatting (see `man tmux` for complete list) or run the color_palette.sh in the tmux-powerline root directory:
#   * Named colors, e.g. black, red, green, yellow, blue, magenta, cyan, white
#   * Hexadecimal RGB string e.g. #ffffff
#   * 'default_fg_color|default_bg_color' for the default theme bg and fg color
#   * 'default' for the default tmux color.
#   * 'terminal' for the terminal's default background/foreground color
#   * The numbers 0-255 for the 256-color palette. Run `tmux-powerline/color-palette.sh` to see the colors.
# * non_default_separator - specify an alternative character for this segment's separator
#   * 'default_separator' for the theme default separator
# * separator_background_color - specify a unique background color for the separator
#   * 'no_sep_bg_color' for using the default coloring for the separator
# * separator_foreground_color - specify a unique foreground color for the separator
#   * 'no_sep_fg_color' for using the default coloring for the separator
# * spacing_disable - remove space on left, right or both sides of the segment:
#   * "no_spacing_disable" - don't disable spacing (default)
#   * "left_disable" - disable space on the left
#   * "right_disable" - disable space on the right
#   * "both_disable" - disable spaces on both sides
#   * - any other character/string produces no change to default behavior (eg "none", "X", etc.)
#
# * separator_disable - disables drawing a separator on this segment, very useful for segments
#   with dynamic background colours (eg tmux_mem_cpu_load):
#   * "no_separator_disable" - don't disable the separator (default)
#   * "separator_disable" - disables the separator
#   * - any other character/string produces no change to default behavior
#
# Example segment with separator disabled and right space character disabled:
# "hostname 33 0 {TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD} 0 0 right_disable separator_disable"
#
# Example segment with spacing characters disabled on both sides but not touching the default coloring:
# "hostname 33 0 {TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD} no_sep_bg_color no_sep_fg_color both_disable"
#
# Example segment with changing the foreground color of the default separator:
# "hostname 33 0 default_separator no_sep_bg_color 120"
#
## Note that although redundant the non_default_separator, separator_background_color and
# separator_foreground_color options must still be specified so that appropriate index
# of options to support the spacing_disable and separator_disable features can be used
# The default_* and no_* can be used to keep the default behaviour.

# shellcheck disable=SC1143,SC2128
if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
		"tmux_session_info ${TMUX_POWERLINE_SESSION_ACCENT} 232"
		"last_session ${TMUX_POWERLINE_DEFAULT_BG} 245"
		"separator ${TMUX_POWERLINE_DEFAULT_BG} ${TMUX_POWERLINE_DEFAULT_BG}"
	)
fi

# shellcheck disable=SC1143,SC2128
if [ -z "$TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		"date ${TMUX_POWERLINE_DEFAULT_BG} ${TMUX_POWERLINE_TIME_ACCENT}"
		"time ${TMUX_POWERLINE_DEFAULT_BG} ${TMUX_POWERLINE_TIME_ACCENT} ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"
		"battery_if_present ${TMUX_POWERLINE_ACCENT} 232"
		"hostname_laptop ${TMUX_POWERLINE_ACCENT} 232"
		"hostname_pc ${TMUX_POWERLINE_ACCENT} 232"
	)
fi
