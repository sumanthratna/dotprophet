# @sumanthratna's dotfiles

## Useful [Aliases](./home/dot_config/zsh/exact_aliases)

### [`quit`](./home/dot_config/zsh/exact_aliases/quit)

- quits the current terminal app in macOS
- usage: `quit`

### [`rmr`](./home/dot_config/zsh/exact_aliases/rmr)

- recursively removes a file
- usage: `rmr .DS_Store`
- adapted from <https://stackoverflow.com/a/45647470/7127932>

### [`email`](./home/dot_config/zsh/exact_aliases/email)

- returns a list of emails given a social media handle
- useful for when you know someone's GitHub username and need to contact them via email
- usage: `email github AutinMitra`
- I wrote this one myself

### [`show`](./home/dot_config/zsh/exact_aliases/show)

- lists all the files in a pretty way, using [`eza`](https://github.com/eza-community/eza)
- usage: `show` or `show dir/` or `show file`
- I wrote this one myself (this wasn't hard to write)

## Setup

[chezmoi](https://www.chezmoi.io/) manages these dotfiles. `home/` is the
source state (see `.chezmoiroot`); `~` is the target. Targets are macOS
(Homebrew) and Coder workspaces (Ubuntu x86_64, where only `~` survives a
rebuild).

### Install

macOS:

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
brew install chezmoi  # install.sh uses it rather than installing its own copy
git clone https://github.com/sumanthratna/dotprophet.git ~/dotprophet
~/dotprophet/install.sh
```

`install.sh` asks "Work machine?" once; the answer picks the git email. Done
when `chezmoi diff --exclude=scripts` prints nothing.

Coder: set this repo as your dotfiles repo. Coder runs `install.sh` on every
workspace start, without prompting; `CODER` being set marks it a work machine.

### Changing things

- **Edit the source state, then `chezmoi apply`.** `chezmoi edit --apply ~/.zshrc`
  opens the right source file. An edit made directly in `~` is overwritten on
  the next apply; `chezmoi re-add` copies it back into `home/` first.
- **`rcfiles/` is the exception.** nvim (`lazy-lock.json`) and Claude Code
  (`settings.json`) rewrite their own config, so chezmoi symlinks these into
  `~` and either path edits the repo copy.
- **Command-line tools** live in `home/.chezmoidata/packages.yaml`, one entry
  per tool: `brew` installs it on macOS, `github` downloads its release binary
  into `~/.local/bin` on Coder. An entry without `github` is macOS-only. Find
  the release asset name with
  `gh api repos/OWNER/REPO/releases/latest --jq '.assets[].name'`.
- **Self-updating tools** (Claude Code, Codex) use their vendor installer in a
  `run_once_` script under `home/.chezmoiscripts/`.
- **zsh plugins** live in `home/.chezmoidata/zsh.yaml`, in load order.
- **System state on Coder** (apt packages, the login shell) resets on rebuild,
  so it belongs in `home/.chezmoiscripts/run_before_linux-system.sh.tmpl`,
  which runs on every apply.
- **Machine differences**: `.chezmoiignore` drops whole files per OS; inside a
  template, branch on `.chezmoi.os` or `.work` (work vs personal machine).

### Verifying

- `chezmoi diff` previews an apply; `chezmoi execute-template < FILE.tmpl`
  renders one template.
- Coder, locally: copy the repo to `~/.config/coderv2/dotfiles` in
  `docker run --platform linux/amd64 -e CODER=true ubuntu:24.04` (as a
  non-root user with passwordless sudo, plus `git` and `curl`), then run
  `install.sh`. Pass `GITHUB_TOKEN` to stay under GitHub's 60 requests/hour
  limit. Done when every tool in `~/.local/bin` prints its version and
  `zsh -ic exit` prints no errors.

`.f` jumps to this repo.

## Terminal Workflow

Useful tips from [Macworld](http://hints.macworld.com/article.php?story=20140114080042155#comments) ([outdated permalink](http://hints.macworld.com/comment.php?mode=view&cid=132941)):

- ⌃ is control
- ⎋ is escape
- ⌥ is option/alt

> - **⌃ + A** Go to the beginning of the line you are currently typing on
> - **⌃ + E** Go to the end of the line you are currently typing on
> - **⌃ + L** Clears the Screen, similar to the clear command
> - **⌃ + U** Clears the line before the cursor position. If you are at the end of the line, clears the entire line.
> - **⌃ + H** Same as backspace
> - **⌃ + R** Let’s you search through previously used commands
> - **⌃ + C** Kill whatever you are running
> - **⌃ + D** Exit the current shell
> - **⌃ + Z** Puts whatever you are running into a suspended background process. `fg` restores it.
> - **⌃ + W** Delete the word before the cursor
> - **⌃ + K** Clear the line after the cursor
> - **⌃ + T** Swap the last two characters before the cursor
> - **⎋ + T** Swap the last two words before the cursor
> - **⌥ + F** Move cursor forward one word on the current line
> - **⌥ + B** Move cursor backward one word on the current line

- **⌥ + [click]** Move the cursor to the location of the mouse
