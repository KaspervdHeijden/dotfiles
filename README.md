## Dotfiles

With this repository I can quickly setup a shell environment to my liking:)

### Installation

Checkout this repository.
From the home directory, add the following line to the `.bashrc`, or `~/.bash_profile` file:
```sh
source <dotfiles-dir>/bash/bashrc.sh;
```

In addition, to make bash autocomplete case insensitive, do:
```sh
[[ ! -f ~/.inputrc && -f /etc/.inputrc ]] && echo '$include /etc/.inputrc' > ~/.inputrc;
echo 'set completion-ignore-case On' >> ~/.inputrc;
```

If you use zsh, add the following to the `.zshrc` file:
```sh
source <dotfiles-dir>/zsh/zshrc.sh;
```

Before you can use the `cds` function, you must first run the `repo-search` command.
