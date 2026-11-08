# fancy-marks.nvim

## Overview

This plugin is designed to provide a way to view; jump to; and delete marks in Neovim, as well as highlight them when an overlay is enabled.

## Features

Through `opts`, you can configure features:
- `use_default_mappings`: whether to use the default key mappings (default: true)
- `width`: the width of the popup window (default: "80%")
- `height`: the height of the popup window (default: "60%")

Open the window with `require("fancy-marks").open_window()`. The window will display a list of actives global and local marks. Use <CR> on a mark to jump to it.

## Installation

Assuming the plugin is in the _runtimepath_, the setup function can be called with `require("fancy-marks").setup({})` (or with your preferred plugin manager).

## TODO

- add overlay with toggle
