# Filemanager Plugin

A simple plugin that allows for easy navigation of a file tree.

Example gif coming soon...

**Installation:** run `plugin install filemanager` and restart Micro.

# Table Of Content

* [Basics](#basics)
* [Commands and Keybindings](#commands-and-keybindings)
* [Rebinding](#rebinding-things)
* [In-depth](#commands-in-depth)

## Basics

The top line always has the current directory's path to show you where you are.  
The `..` near the top is used to move back a directory, from your current position.

All directories have a `/` added to the end of it, and are syntax-highlighted as a `special` character.  
If it hasn't been uncompressed, there will be a `+` to the left of it.  
If it has been uncompressed, there will be a `-` to the left of it.

**NOTE:** If you change files without using the plugin, it can't know what you did. The only fix is to close and open the tree.

### Commands and Keybindings

The keybindings below are the equivalent to Micro's defaults, and not actually set by the plugin. If you've changed any of those keybindings, then that key is used instead.

| Command  | Keybinding(s)              | What it does                                                                                |
| :------- | :------------------------- | :------------------------------------------------------------------------------------------ |
| `tree`   | -                          | Open or close the tree                                                                      |
| -        | <kbd>Tab</kbd> & MouseLeft | Open a file, or go into the directory. Goes back a dir if on `..`                           |
| -        | <kbd>→</kbd>               | Uncompress a directory's content under it                                                   |
| -        | <kbd>←</kbd>               | Compress any uncompressed content under a directory                                         |
| -        | <kbd>Shift ⬆</kbd>         | Go to the target's parent directory                                                         |
| -        | <kbd>Alt Shift {</kbd>     | Jump to the previous directory in the view                                                  |
| -        | <kbd>Alt Shift }</kbd>     | Jump to the next directory in the view                                                      |
| `rm`     | -                          | Prompt to delete the target file/directory your cursor is on                                |
| `rename` | -                          | Rename the file/directory your cursor is on, using the passed name                          |
| `touch`  | -                          | Make a new file under/into the file/directory your cursor is on, using the passed name      |
| `mkdir`  | -                          | Make a new directory under/into the file/directory your cursor is on, using the passed name |

**Note:** The <kbd>Ctrl w</kbd> keybinding is to switch which buffer your cursor is on.  
This isn't specific to the plugin, it's just part of Micro, but many people seem to not know this.

#### Rebinding Things

Do you want to keybind any of the operations/commands/whatever?  
The table below specifies what you need to add to your [bindings.json in your Micro config](https://github.com/zyedidia/micro/blob/master/runtime/help/keybindings.md#rebinding-keys).

| Command/Keybinding         | Used in `bindings.json`               |
| :------------------------- | :------------------------------------ |
| `tree`                     | `filemanager.toggle_tree`             |
| <kbd>Tab</kbd> & MouseLeft | `filemanager.try_open_at_cursor`      |
| <kbd>Shift ⬆</kbd>         | `filemanager.goto_parent_dir`         |
| <kbd>Alt Shift {</kbd>     | `filemanager.goto_next_dir`           |
| <kbd>Alt Shift }</kbd>     | `filemanager.goto_prev_dir`           |
| `rm`                       | `filemanager.prompt_delete_at_cursor` |
| `rename`                   | `filemanager.rename_at_cursor`        |
| `touch`                    | `filemanager.new_file`                |
| `mkdir`                    | `filemanager.new_dir`                 |

#### Commands In-Depth

Note: While these commands are Unix-like, there shouldn't be any issue on non-Unix systems like Windows, and they should still work the same.

* `tree`  
  This just opens/closes the tree. Nothing special.

* `rm`  
  It deletes the file/dir after prompting for confirmation. Nothing much to say.

* `rename`, `touch`, and `mkdir`  
  These require a name to be passed when calling. ex: `rename newnamehere`, `touch filenamehere`, `mkdir dirnamehere`.  
  If the passed name already exists in the current dir, it will cancel instead of overwriting (for safety).
