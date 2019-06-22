## Dotfiles

With this repository I can quickly setup a shell environment to my liking:)

### Installation

First, clone this repository. I suggest to clone from the home dir. Then, source the `install.sh` file.
```sh
cd && git clone 'https://github.com/KaspervdHeijden/dotfiles.git' && . dotfiles/install.sh;
```

If you're using bash, you can make bash autocomplete case insensitive by doing:
```sh
[[ ! -f ~/.inputrc && -f /etc/.inputrc ]] && echo '$include /etc/.inputrc' > ~/.inputrc;
echo 'set completion-ignore-case On' >> ~/.inputrc;
```
