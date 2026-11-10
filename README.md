# fancy-marks.nvim

## Overview

This plugin is designed to provide a way to view; jump to; and delete marks in Neovim.

## Features

Through `opts`, you can configure features:
- `use_default_mappings`: whether to use the default key mappings (default: true)
- `num_lines_preview`: the number of lines to show in the preview window (default: 5)
- `width`: the width of the popup window (default: "80%")
- `height`: the height of the popup window (default: "60%")

Open the window with `require("fancy-marks").open_window()`. The window will display a list of actives global and local marks. Use <CR> on a mark to jump to it. When the cursor is on a mark, a preview window will show lines surrounding a mark.

## Installation

Assuming the plugin is in the _runtimepath_, the setup function can be called with `require("fancy-marks").setup({})` (or with your preferred plugin manager).

## TODO

- add overlay with toggle

## Note

This plugin is an excercise in developing Neovim plugins in Lua. There are much better alternatives for managing marks in Neovim. However, this can function as a useful lightweight plugin for simple mark management.
