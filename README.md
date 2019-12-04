## Start with a clean slate

This will create an identical installation on any Mac with a single command.

This lets you to restore a machine without having to deal with the mess that was
the state of a previous installation, or painstakingly babysit the process
step-by-step.

Unlike other solutions, this approach is extremely simple. It is just a short
shell script with a pre-defined directory structure. No configuration files or
custom commands are necessary.

## Usage

Instead, just run the following:

```sh
# Clone your configuration repo wherever you like. For example:
git clone --recursive https://github.com/{you}/{your-repo} ~/.dotfiles

# Run this script, typically included as a submodule.
#
# If on a new machine, once finished, restart and run again to ensure system 
# settings are applied correctly.
~/.dotfiles/zero/setup
```

... and you'll be back up and running, with all of your applications and command
line utilities re-installed (and configurations restored).

During setup, you may asked for your password as some commands require admin
privileges. Each of these will be printed before running.

The setup script will do the following, in order:

1. Check for system and application updates.
2. Install packages and applications via Homebrew or the system package manager.
3. Run any scripts under `run/before` in alphabetical order.
4. Apply system defaults described in `defaults.yml`.
5. Symlink configuration files listed under `symlinks` to the home directory.
6. Run the remaining scripts under `run/after` in alphabetical order.

This script is idempotent, and can be safely invoked again to update tools
and ensure everything has been installed correctly.

It will **not** wipe over files that already exist when symlinking or at any
other point in the process, aside from what is done by system upgrade tools or
in your own custom before & after scripts.

If you'd like, you can write an alias so you can invoke this script at any time
to apply updates to all tools on your system:

```sh
alias update="$HOME/.dotfiles/zero/setup"
$ update
```

Initially, this was encapsulated in a Python library called
[cider](https://github.com/msanders/cider), but now that Homebrew added back
Brewfile support it has been migrated to this simple shell script and directory
structure instead.

This structure in `~/.dotfiles` (or wherever you choose to store it) is expected
to look like this:

```
- Brewfile
- defaults.yml
- symlinks/
    -> name/ # Alias to organize, for example "zsh", "vim", etc.
        => file or directory # Exact name of file or directory to symlink.
- run/
    -> before/
        => [ ... executable scripts ... ]
    -> after/
        => [ ... executable scripts ... ]
- zero/
```

## Installation

It's recommended to integrate this script as a submodule:

```sh
cd ~/.your-dotfile-repo
git submodule add https://github.com/zero-sh/zero.sh zero
```

Then make sure to run `git submodule update --init` after pulling to instantiate
(or use the `--recursive` flag during cloning as shown above).

To update to the latest upstream changes, run: 

```sh
git submodule update --remote --merge
```

## Working examples

To see how this works out in practice, here are some repos that use `zero.sh`.

- [msanders/dotfiles](https://github.com/msanders/dotfiles)

> Add yours here — send a PR.

## Roadmap & missing features

- Linux/Unix support. This should be pretty straightforward, but requires
  accounting for additional system update tools and package managers that I
  haven't had time for yet.

- Currently it's not possible to specify a target for symlinks; they are just
  all expanded to the home directory, matching the nested directory structure
  they are contained in under `symlinks/`. This works fine for my use-case but
  not sure if it will be enough for others.

- GNU stow is a neat tool, but doesn't offer the same level of utility or error
  handling that Cider previously did. It would be nice to offer a more modern
  alternative.

## Dependencies

These dependencies are required & installed when running the setup script:

- Xcode Command Line Tools.
- [Homebrew](https://brew.sh).
- `apply-user-defaults` installed via Homebrew.
- [`mas`](https://github.com/mas-cli/mas) installed via Homebrew.
- [`stow`](https://www.gnu.org/software/stow/) installed via Homebrew.

## Non-Goals

This tool is intended to be a very minimal approach to system configuration. If
you are looking for something more full-featured, e.g. that provides a
comprehensive CLI or complex features for managing many machines at once, there
are other solutions available. In my experience just dealing with my own
machines, this was all that was necessary.

If you do decide to go with something else (or your own bootstrap script), there
will only be one file to replace. This doesn't install anything outside of the
cloned directory aside from the few dependencies listed above.

## Contributions

If you are interested in this project, please consider contributing. Here are a
few ways you can help:

- Report issues.
- Fix bugs and submit pull requests.
- Write, clarify, or fix documentation.
- Suggest or add new features.

## Credit

This is partly inspired by [@gerhard](https://github.com/gerhard)'s
[setup](https://github.com/gerhard/setup), in addition to [this blog
post](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)
on GNU Stow by Brandon Invergo.
