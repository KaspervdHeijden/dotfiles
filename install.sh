dotfiles_dir=$(realpath "$(dirname "${0}")");
echo "Including dotfiles from ${dotfiles_dir}...";

for shell_name in bash zsh; do
    file=~/.${shell_name}rc;
    if grep -q 'DOTFILES_DIR=' "${file}" 2>/dev/null; then
        continue;
    fi

    echo "+ ${shell_name}";
    echo '' >> "${file}";
    echo '# Include dotfiles' >> "${file}";
    echo "export DOTFILES_DIR='${dotfiles_dir}';" >> "${file}";
    echo ". \"\${DOTFILES_DIR}/${shell_name}/${shell_name}rc.sh\";" >> "${file}";
done;

echo 'Done.';

cur_shell=$(getent passwd "${USER}" | cut -d':' -f7 | awk -F'/' '{print $NF}');
if [ -f "${dotfiles_dir}/${cur_shell}/${cur_shell}rc.sh" ]; then
    echo "Sourcing '${dotfiles_dir}/${cur_shell}/${cur_shell}rc.sh'...";

    export DOTFILES_DIR="${dotfiles_dir}";
    . "${dotfiles_dir}/${cur_shell}/${cur_shell}rc.sh";
fi

