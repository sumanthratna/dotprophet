# @sumanthratna's dotfiles

## Useful [Aliases](./aliases)

### [`quit`](./aliases/quit)

- quits the current terminal app in macOS
- usage: `quit`

### [`rmr`](./aliases/rmr)

- recursively removes a file
- usage: `rmr .DS_Store`
- adapted from <https://stackoverflow.com/a/45647470/7127932>

### [`email`](./aliases/email)

- returns a list of emails given a social media handle
- useful for when you know someone's GitHub username and need to contact them via email
- usage: `email github AutinMitra`
- I wrote this one myself

### [`show`](./aliases/show)

- lists all the files in a pretty way, using [`eza`](https://github.com/eza-community/eza)
- usage: `show` or `show dir/` or `show file`
- I wrote this one myself (this wasn't hard to write)

## Setup

```zsh
cd ~
git clone https://github.com/sumanthratna/dotprophet.git

cd /tmp
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
cd ~/dotprophet
brew bundle

# Disable Spotlight Cmd+Space and set Raycast hotkey to Cmd+Space
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "
<dict>
  <key>enabled</key><false/>
  <key>value</key>
  <dict>
    <key>parameters</key>
    <array>
      <integer>32</integer>
      <integer>49</integer>
      <integer>1048576</integer>
    </array>
    <key>type</key><string>standard</string>
  </dict>
</dict>"
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
defaults write com.raycast.macos raycastGlobalHotkey -string "Command-49"

cd ~

git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

ln -s ~/dotprophet/rcfiles/zshrc ~/.zshrc
ln -s ~/dotprophet/gitconfig ~/.gitconfig

git config --file ~/.gitconfig.local user.email "<EMAIL>"

mkdir -p ~/.config
ln -s ~/dotprophet/rcfiles/nvim ~/.config/nvim
nvim --headless "+Lazy! sync" +qa

ln -s ~/dotprophet/ssh_config ~/.ssh/config

mkdir -p ~/.config/ghostty
ln -s ~/dotprophet/rcfiles/ghostty/config ~/.config/ghostty/config
ln -s ~/dotprophet/rcfiles/ghostty/zellij-keybinds ~/.config/ghostty/zellij-keybinds

ln -s ~/dotprophet/rcfiles/zellij ~/.config/zellij

curl -fsSL https://claude.ai/install.sh | bash
mkdir -p ~/.claude/hooks
ln -s ~/dotprophet/rcfiles/claude/settings.json ~/.claude/settings.json
ln -s ~/dotprophet/rcfiles/claude/hooks/notify-focus.sh ~/.claude/hooks/notify-focus.sh

# Register Raycast extensions (npm run dev only needs to register, Ctrl+C immediately)
pushd ~/dotprophet/raycast/extensions/zellij && npm install && npm run dev; popd

defaults write com.apple.finder AppleShowAllFiles YES
```

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
