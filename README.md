# Filemanager Plugin

A simple plugin that allows for easy navigation of a file tree.

Place this folder in `~/.config/micro/plugins/` and restart micro:
> git clone https://github.com/NicolaiSoeborg/filemanager-plugin.git ~/.config/micro/plugins/filemanager

Now it will be possible to open a navigation panel by running 
the command `tree` (<kbd>Ctrl</kbd> + <kbd>E</kbd>) or creating
a keybinding like so:
```
{
	"CtrlW":  "filemanager.ToggleTree"
}
```

## Example

![filemanager](https://i.imgur.com/MBou7Hb.png "Filemanager")

## Issues

Please use the issue tracker to fill issues or feature requests!


### Known Issues

* Limited Windows support (also; can only read files from `C:`)

