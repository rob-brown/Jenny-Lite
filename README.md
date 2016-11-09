# Jenny Lite

## Summary

`Jenny Lite` is a lightweight inline template expander designed to be mostly language agnostic.  

## Installation

`Jenny Lite` can be installed by simply running the provided install script.

```bash
./install.sh
```

This will install the executable `jenny` to `/usr/local/bin`. `Jenny Lite` may also be uninstalled with the provided uninstall script.

```bash
./uninstall.sh
```

Alternatively, you can build `Jenny Lite` yourself. Then you can run it locally or move it wherever you need.

```bash
MIX_ENV=prod mix do deps.get, escript.build
mv jenny /some/path
```

## Usage

### Specify Expansions

When `Jenny Lite` expands a file, it looks for the following pattern:

```
<<<EXPAND_SPEC>>>
{
  "template": "some template file",
  "inputs": {
    // Whatever values you need for your template.
  }
}
<<<START_EXPAND>>>
<<<END_EXPAND>>>
```

The spec is written in JSON. The two top-level keys are `template` and `inputs`. The `template` key should reference a template file relative to the current file. The `inputs` key is an arbitrary dictionary that is passed to the template engine.

The result of the expanded template are placed between the `<<<START_EXPAND>>>` and
`<<<END_EXPAND>>>` delimiters. Whenever the spec changes, the next time `Jenny Lite` is run, it will replace the previous expansion with the new one.

All the delimiters must be placed on their own lines. Only valid JSON may appear between `<<<EXPAND_SPEC>>>` and `<<<START_EXPAND>>>`. The preferred way to do this is with multi-line comments.

Here is a multi-line comment example:

```c
/* <<<EXPAND_SPEC>>>
{
  "template": "some template file",
  "inputs": {
    // Whatever values you need for your template.
  }
}
<<<START_EXPAND>>> */

/* <<<END_EXPAND>>> */
```

### Templates

Templates are currently written in [EEx](http://elixir-lang.org/docs/stable/eex/EEx.html). This allows templates to use simple value insertion, conditionals, `for` loops, or anything else allowed by Elixir.

For most projects, you probably want to have all your templates in a single directory. Then all your specified expansions can easily reference the appropriate template.

### Perform Expansions

The executable `jenny` is called with one or more files. For example:

```bash
jenny User.swift Book.swift Database.swift
jenny sources/*.swift
jenny **/*.swift
```

You may also list files to ignore. For example:

```bash
jenny **/*.swift --ignore test/*.swift
```

If you are using an IDE, it is recommended that you run `jenny` as part of your build process. You must also run `jenny` before running the compiler. 

## License

`Jenny Lite` uses the MIT License (see `LICENSE`).
