#!/bin/sh --

cur_dir=$(realpath $(dirname "${0}"));
echo "Including dotfiles from ${cur_dir}";

for shell_name in bash zsh; do
    file="$(echo ~)/.${shell_name}rc";
    if $(grep 'DOTFILES_DIR=' "${file}"); then
        continue;
    fi

    echo "${shell_name}";
    echo '# Include dotfiles' >> "${file}";
    echo "export DOTFILES_DIR='${cur_dir}';" >> "${file}";
    echo "source '${cur_dir}/${shell_name}/${shell_name}rc.sh';" >> "${file}";
done;

echo 'Done. Please restart your shell, and call repo-search';
