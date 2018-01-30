# Filemanager Plugin

A simple plugin that allows for easy navigation of a file tree.

![Example picture](./example.jpg?raw=true "Example")

**Installation:** run `plugin install filemanager` and restart Micro.

## Basics

The top line always has the current directory's path to show you where you are.\
The `..` near the top is used to move back a directory, from your current position.

All directories have a `/` added to the end of it, and are syntax-highlighted as a `special` character.\
If it hasn't been uncompressed, there will be a `+` to the left of it. If it has been uncompressed, it will be a `-` instead.

If you want to disable dotfiles from being shown, run `set filemanager-showdotfiles false` in Micro, then close & open the tree.\
If you want to disable VCS-ignored (aka `.gitignore`) files from being shown, run `set filemanager-showignored false` in Micro, then close & open the tree.

**NOTE:** If you change files without using the plugin, it can't know what you did. The only fix is to close and open the tree.

### Commands and Keybindings

The keybindings below are the equivalent to Micro's defaults, and not actually set by the plugin. If you've changed any of those keybindings, then that key is used instead.

If you want to [keybind](https://github.com/zyedidia/micro/blob/master/runtime/help/keybindings.md#rebinding-keys) any of the operations/commands, bind to the labeled API in the table below.

| Command  | Keybinding(s)              | What it does                                                                                | API for `bindings.json`               |
| :------- | :------------------------- | :------------------------------------------------------------------------------------------ | :------------------------------------ |
| `tree`   | -                          | Open/close the tree                                                                         | `filemanager.toggle_tree`             |
| -        | <kbd>Tab</kbd> & MouseLeft | Open a file, or go into the directory. Goes back a dir if on `..`                           | `filemanager.try_open_at_cursor`      |
| -        | <kbd>→</kbd>               | Uncompress a directory's content under it                                                   | `filemanager.uncompress_at_cursor`    |
| -        | <kbd>←</kbd>               | Compress any uncompressed content under a directory                                         | `filemanager.compress_at_cursor`      |
| -        | <kbd>Shift ⬆</kbd>         | Go to the target's parent directory                                                         | `filemanager.goto_parent_dir`         |
| -        | <kbd>Alt Shift {</kbd>     | Jump to the previous directory in the view                                                  | `filemanager.goto_next_dir`           |
| -        | <kbd>Alt Shift }</kbd>     | Jump to the next directory in the view                                                      | `filemanager.goto_prev_dir`           |
| `rm`     | -                          | Prompt to delete the target file/directory your cursor is on                                | `filemanager.prompt_delete_at_cursor` |
| `rename` | -                          | Rename the file/directory your cursor is on, using the passed name                          | `filemanager.rename_at_cursor`        |
| `touch`  | -                          | Make a new file under/into the file/directory your cursor is on, using the passed name      | `filemanager.new_file`                |
| `mkdir`  | -                          | Make a new directory under/into the file/directory your cursor is on, using the passed name | `filemanager.new_dir`                 |

#### Notes

* `rename`, `touch`, and `mkdir` require a name to be passed when calling.\
  Example: `rename newnamehere`, `touch filenamehere`, `mkdir dirnamehere`.\
  If the passed name already exists in the current dir, it will cancel instead of overwriting (for safety).

* The <kbd>Ctrl w</kbd> keybinding is to switch which buffer your cursor is on.\
  This isn't specific to the plugin, it's just part of Micro, but many people seem to not know this.
