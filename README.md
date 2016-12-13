# Filetree Plugin

A simple plugin that allows for easy navigation of a file tree.

Place this folder in `~/.config/micro/plugins/` and restart micro.

Now it will be possible to open a navigation panel by running the command `tree` (ctrl + e).

## Example
![filetree cli](https://i.imgur.com/gO5CnT4.png "Filetree CLI")


## Known Issues

* Limited Windows support (can only read files from `C:`)

* Opening of (huge) files will be slow


## Requirements

To better support all filesystems, this plugin uses `LuaFileSystem`.

Installing on windows:

1 Install LuaRocks

    * Get newest ("win32.zip" package here)[https://keplerproject.github.io/luarocks/releases/].

    * Unpack and run `install.bat /L`

    * Go to the installed LuaRocks dir, e.g. `C:\Program Files (x86)\LuaRocks\` and run `luarocks.bat install luafilesystem`

      * e.g. `"C:\Program Files (x86)\LuaRocks\luarocks.bat" install luafilesystem`

      * If you get compiling errors, then install Visual Studio and open `Developer Command Prompt for Visual Studio`
      (https://msdn.microsoft.com/en-us/library/ms229859(v=vs.110).aspx) and run the above command as admin.

    *

2 TODO
