# Fish shell notes

When encountering following error after <tab> completing git commands:

```sh
tr: extra operand ‘basename’
Try 'tr --help' for more information.
contains: Key not specified
```

Try to apply this diff to the `/usr/share/fish/completions/git.fish`:

```diff
2233c2233
<     set -l subcommand (path basename $file)
---
>     set -l subcommand (basename $file)
```
