# Filetree Plugin

A simple plugin that allows for easy navigation of a file tree.

Place this folder in `~/.config/micro/plugins/` and restart micro:
> git clone https://github.com/NicolaiSoeborg/filetree-plugin.git ~/.config/micro/plugins/filetree

Now it will be possible to open a navigation panel by running 
the command `tree` (ctrl + e) or creating a keybinding like so:
```
{
	"Ctrl-E":  "filetree.OpenTree"
}
```

## Example

![filetree cli](https://i.imgur.com/MBou7Hb.png "Filetree CLI")

## Issues

Please use the issue tracker to fill issues or feature requests!


### Known Issues

* Limited Windows support (also; can only read files from `C:`)

