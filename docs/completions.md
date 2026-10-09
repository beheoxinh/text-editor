# Completions

"Code Completions" provided by Language Servers (LSPs) automatically installed
by TextEditor or via [TextEditor Language Extensions](./languages.md).

## Language Server Code Completions {#code-completions}

When there is an appropriate language server available, TextEditor will provide
completions of variable names, functions, and other symbols in the current file.
You can disable these by adding the following to your TextEditor `settings.jsonc`
file:

```json
"show_completions_on_input": false
```

You can manually trigger completions with `ctrl-space` or by triggering the
`editor::ShowCompletions` action from the command palette.

For more information, see:

- [Configuring Supported Languages](./configuring-languages.md)
- [List of TextEditor Supported Languages](./languages.md)
