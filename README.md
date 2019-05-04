## Dotfiles

With this repository I can quickly setup a shell environment to my liking:)

### Installation

Clone this repository.
From the home directory, add the following line to the `.bashrc`, or `~/.bash_profile` file:
```sh
source <dotfiles-dir>/bash/bashrc.sh;
```

After cloning the repository, call <path-to-dotfiles>install.sh to add the required lines
to the rc files located in your homedir.

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
