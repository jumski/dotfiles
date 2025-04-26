# Tool-Agnostic Color Schemes

This directory contains color schemes in a standardized JSON format that can be used to generate theme files for various tools and applications.

## Format Description

Each color scheme is stored in a JSON file with the following structure:

```json
{
  "name": "Theme Name",
  "author": "Author Name",
  "description": "A brief description of the theme",
  "type": "dark|light",
  "colors": {
    "bg_default": "#hexcolor",
    "bg_dark": "#hexcolor",
    "bg_highlight": "#hexcolor",
    "bg_gutter": "#hexcolor",
    "bg_visual": "#hexcolor",
    "fg_default": "#hexcolor",
    "fg_dark": "#hexcolor",
    "fg_gutter": "#hexcolor",
    "fg_muted": "#hexcolor",
    "border": "#hexcolor",
    "selection": "#hexcolor",
    "comment": "#hexcolor",
    "black": "#hexcolor",
    "red": "#hexcolor",
    "green": "#hexcolor",
    "yellow": "#hexcolor",
    "blue": "#hexcolor",
    "magenta": "#hexcolor",
    "cyan": "#hexcolor",
    "white": "#hexcolor",
    "orange": "#hexcolor",
    "pink": "#hexcolor"
  },
  "semantic": {
    "function": "#hexcolor",
    "variable": "#hexcolor",
    "constant": "#hexcolor",
    "type": "#hexcolor",
    "keyword": "#hexcolor",
    "string": "#hexcolor",
    "operator": "#hexcolor",
    "property": "#hexcolor",
    "parameter": "#hexcolor",
    "numeric": "#hexcolor",
    "error": "#hexcolor",
    "warning": "#hexcolor",
    "success": "#hexcolor",
    "info": "#hexcolor"
  }
}
```

### Color Groups

- **colors**: Basic palette colors for UI elements
  - Background colors (`bg_*`)
  - Foreground colors (`fg_*`)
  - Standard terminal colors
  - UI element colors (border, selection, etc.)

- **semantic**: Colors for specific code elements and syntax highlighting
  - Language constructs (function, variable, etc.)
  - Status indicators (error, warning, etc.)

## Available Color Schemes

- **tokyonight-night.json**: Dark theme inspired by Downtown Tokyo at night
- **tokyonight-storm.json**: Dark theme with a slightly lighter background
- **tokyonight-moon.json**: Darker variant with more blue tones
- **tokyonight-day.json**: Light variant of the Tokyo Night theme

## Usage

Use these files as source data to generate specific theme files for various applications (e.g., Neovim, Tmux, VS Code, etc.).

Example usage in a theme generator script:

```bash
# Example Python script that could generate a theme file for an application
python generate_theme.py --source colors/tokyonight-night.json --target ~/.config/app/theme.conf
```