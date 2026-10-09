# Command-line Interface

TextEditor has a CLI, on Linux this should come with the distribution's TextEditor package
(binary name can vary from distribution to distribution, `text-editor` will be used
later for brevity). For macOS, the CLI comes in the same package with the editor
binary, and could be installed into the system with the `cli: install` TextEditor
command which will create a symlink to the `/usr/local/bin/text-editor`. It can also be
built from source out of the `cli` crate in this repository.

Use `text-editor --help` to see the full list of capabilities. General highlights:

- Opening another empty TextEditor window: `text-editor`

- Opening a file or directory in TextEditor: `text-editor /path/to/entry` (use `-n` to open
  in the new window)

- Reading from stdin: `ps axf | text-editor -`

- Starting TextEditor with logs in the terminal: `text-editor --foreground`

- Uninstalling TextEditor and all its related files: `text-editor --uninstall`
