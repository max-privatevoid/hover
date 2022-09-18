# Hover - Home overlay

Tired of programs you don't even intend on keeping vomiting all over your home directory?
Frequent user of `cd $(mktemp -d)`? Read on.

## Intro

Hover creates an overlay directory for your `$HOME`.
The files in your original `$HOME` are all there, but any changes such as
modifying, adding or removing files are lost after exiting Hover.

## Installation

Hover is distributed as a Nix flake.

Install it into your profile:
```console
$ nix profile install github:max-privatevoid/hover
```

Try it in a temporary shell
(it won't create any files in your home directory, promise)
```
$ nix shell github:max-privatevoid/hover
```

## Usage

Hover has a couple of subcommands, listed here.

If you are anywhere inside your home directory when executing Hover,
you will automatically be `cd`'d to the same place within the overlay.

### `hover shell`

Runs your `$SHELL` in a Hover environment. Can also be used by running `hover` with no arguments.

### `hover run`

Runs the specified program, as shown in the example below.
Keep in mind that environment variables on the command line are parsed by the
outer shell, so `hover run echo $HOME` will echo your regular home directory.

```console
$ hover run printenv HOME
/tmp/tmp.oqwgw6BpC7/home
hover: cleaning up
hover: space consumed by temporary home directory:
      0  B /tmp/tmp.oqwgw6BpC7/.upper
```

### `hover nix`

A convenient shortcut for `hover run nix`, so you can do:
```console
$ hover nix shell github:some-person/tool-you-want-to-test
```
