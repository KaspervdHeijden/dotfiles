#!/bin/bash

cur_dir=$(realpath $(dirname "${0}"));
echo "Including dotfiles from ${cur_dir}";

for file in ~/.bashrc ~/.bash_profile ~/.zshrc; do
    if [[ -f "${file}" && ! $(grep 'DOTFILES_DIR=' "${file}") ]]; then
        echo "Initialize dotfiles for '${file}'";

        echo ''  >> "${file}";
        echo '# Include dotfiles' >> "${file}";
        echo "export DOTFILES_DIR='${cur_dir}';" >> "${file}";
        if [[ $(echo "${file}" | grep 'bash') ]]; then
            echo "source '${cur_dir}/bash/bashrc.sh';" >> "${file}";
        else
            echo "source '${cur_dir}/zsh/zshrc.sh';" >> "${file}";
        fi
    fi
done;

echo 'Done. Please restart your shell!';
