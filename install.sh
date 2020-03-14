export DOTFILES_DIR=$(realpath "$(dirname "${0}")");

echo "Including dotfiles from ${DOTFILES_DIR}...";
for shell_name in $(cd "${DOTFILES_DIR}"; ls -d */ | sed 's/\/$//'); do
    if [ ! -f "${DOTFILES_DIR}/${shell_name}/${shell_name}rc.sh" ]; then
        continue;
    fi

    file="${HOME}/.${shell_name}rc";
    if grep -q 'export DOTFILES_DIR=' "${file}" 2>/dev/null; then
        echo " -> config for ${shell_name} already present in ${file}";
        continue;
    fi

    echo " -> adding config for ${shell_name} to ${file}";
    echo '' >> "${file}";
    echo '# Include dotfiles' >> "${file}";
    echo "export DOTFILES_DIR='${DOTFILES_DIR}';" >> "${file}";
    echo ". \"\${DOTFILES_DIR}/${shell_name}/${shell_name}rc.sh\";" >> "${file}";
done;
echo 'Done.';

echo 'Configuring dotfiles...';
if [ ! -f "${HOME}/.config/dotfiles/config.sh" ]; then
    mkdir -p "${HOME}/.config/dotfiles";

    cp "${DOTFILES_DIR}/dotfiles.template.sh" "${HOME}/.config/dotfiles/config.sh";
    if [ -f "${HOME}/.dotfiles" ]; then
        cat "${HOME}/.dotfiles" >> "${HOME}/.config/dotfiles/config.sh";
    fi
fi
echo 'Done.';

cur_shell=$(getent passwd "${USER}" | cut -d':' -f7 | xargs -I{} basename {} | head -n1);
if [ -f "${DOTFILES_DIR}/${cur_shell}/${cur_shell}rc.sh" ]; then
    echo "Sourcing '${DOTFILES_DIR}/${cur_shell}/${cur_shell}rc.sh'...";
    . "${DOTFILES_DIR}/${cur_shell}/${cur_shell}rc.sh";
fi

