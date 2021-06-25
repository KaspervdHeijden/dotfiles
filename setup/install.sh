export DOTFILES_DIR=$(realpath "$(dirname "${0}")/../");

echo "including dotfiles from ${DOTFILES_DIR}...";
for shell_name in $(cd "${DOTFILES_DIR}/shells"; ls -d *); do
    if [ ! -f "${DOTFILES_DIR}/shells/${shell_name}/rc.sh" ]; then
        continue;
    fi

    file="${HOME}/.${shell_name}rc";
    if grep -q 'export DOTFILES_DIR=' "${file}" 2>/dev/null; then
        echo " -> config for ${shell_name} already present in ${file}";
        continue;
    fi

    echo " -> adding config for ${shell_name} to ${file}";

    [ -s "${file}" ] || echo '' >> "${file}";
    echo '# Include dotfiles' >> "${file}";
    echo "export DOTFILES_DIR='${DOTFILES_DIR}';" >> "${file}";
    echo ". \"\${DOTFILES_DIR}/shells/${shell_name}/rc.sh\";" >> "${file}";
done;

echo 'configuring dotfiles...';
if [ ! -f "${HOME}/.config/dotfiles/config.sh" ]; then
    mkdir -p "${HOME}/.config/dotfiles";

    cp "${DOTFILES_DIR}/setup/config.sh" "${HOME}/.config/dotfiles/config.sh";
    if [ -f "${HOME}/.dotfiles" ]; then
        cat "${HOME}/.dotfiles" >> "${HOME}/.config/dotfiles/config.sh" && rm "${HOME}/.dotfiles";
    fi
fi

cur_shell=$(ps l -p $$ | tail -n1 | awk '{print $13}' | sed 's/^-//');
if [ -f "${DOTFILES_DIR}/shells/${cur_shell}/rc.sh" ]; then
    echo "sourcing '${DOTFILES_DIR}/shells/${cur_shell}/rc.sh'...";
    . "${DOTFILES_DIR}/shells/${cur_shell}/rc.sh";
fi
