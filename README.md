## Dotfiles

This repository allows for quickly setup the environment how I like it :)

### Installation

From the home directory, add the following line to the `.bashrc` file
(or `~/.bash_profile` if you use FreeDSB):
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

To start using the `cds` function, please run `repo-search` once first.

