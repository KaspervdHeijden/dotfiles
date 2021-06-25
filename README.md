## Dotfiles

This repository enables me to quickly setup a shell environment to my liking.

### Prerequisites
Dotfiles has the following dependencies:

1. zsh (oh-my-zsh is supported, but not required)
2. git
3. tmux

Personally, I also want:
1. ack
2. tree

Install them all by doing:
```sh
sudo apt -y update && sudo apt -y install zsh git tmux ack-grep tree;
```

### Installation

First, clone this repository. Then source the `install.sh` file:
```sh
cd && git clone 'https://github.com/KaspervdHeijden/dotfiles.git' && . ./dotfiles/setup/install.sh;
```

When using bash, you can make autocomplete case-insensitive by doing:
```sh
[ ! -f ~/.inputrc ] && [ -f /etc/.inputrc ] && echo '$include /etc/.inputrc' > ~/.inputrc;
echo 'set completion-ignore-case On' >> ~/.inputrc;
```

### Notes

#### gitc function
Working with a repository where you don't need (or want) to perform
fork-, master- and/or newline checks, you can pass the appropriate flags every time,
or you can define git variables for them.

Add the variable to the specific repoosity, to not have to pass `-f` anymore:
```sh
git config --local dotfiles.checkFork 0;
```

The same applies to the newline check, to not have to pass `-n` anymore:
```sh
git config --local dotfiles.checkLineEndings 0;
```

This needs to be done on every machine, since git variables aren't part of the repository itself.

You can also use global variables, `$DF_CHECK_FORK`, `$DF_CHECK_LINE_ENDINGS`
and `$DF_CHECK_MASTER`. These can be set in `~/.config/dotfiles/config.sh`
which will be sourced last.

#### Prompt
Setting the variable `$DF_GIT_PROMPT_SHOW_DIRTY` to a non-empty value will
show status information in the prompt, but may significantly slow down the prompt.

You can define the `$DF_DOTFILES_HOST_PROMPT_COLOR_BASH` or `$DF_DOTFILES_HOST_PROMPT_COLOR_ZSH`
variables to control the color for the host part in the prompt. It defaults to green.
