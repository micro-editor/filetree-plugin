# Filetree Plugin

A simple plugin that allows for easy navigation of a file tree.

Place this folder in `~/.config/micro/plugins/` and restart micro.

Now it will be possible to open a navigation panel by running the command `tree` (ctrl + e).


## Example

![filetree cli](https://i.imgur.com/YdBtZx1.png "Filetree CLI")


## Known Issues

* Very limited Windows support (also; can only read files from `C:`)
  See github.com/yuin/gopher-lua/issue/90

* Opening of (huge) files will be slow
