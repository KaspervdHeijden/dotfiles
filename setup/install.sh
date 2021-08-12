DF_ROOT_DIR="$(realpath "$(dirname "${BASH_SOURCE:-$0}")/../")";

echo "including dotfiles from ${DF_ROOT_DIR}...";
for shell_name in $(cd "${DF_ROOT_DIR}/shells"; ls -d *); do
    if [ ! -f "${DF_ROOT_DIR}/shells/${shell_name}/rc.sh" ]; then
        continue;
    fi

    file="${HOME}/.${shell_name}rc";
    if grep -q "${DF_ROOT_DIR}/shells/${shell_name}/rc.sh" "${file}" 2>/dev/null; then
        echo " -> config for ${shell_name} already present in ${file}";
        continue;
    fi

    echo " -> adding config for ${shell_name} to ${file}";

    [ -s "${file}" ] && echo '' >> "${file}";
    echo '# Include dotfiles' >> "${file}";
    echo ". '${DF_ROOT_DIR}/shells/${shell_name}/rc.sh';" >> "${file}";
done;

echo 'configuring dotfiles...';
(
    cd "${DF_ROOT_DIR}" || return 1;
    git config --local dotfiles.checkDefaultBranch 0;
    git config --local dotfiles.checkFork 0;
);

if [ ! -f "${HOME}/.config/dotfiles/config.sh" ]; then
    mkdir -p "${HOME}/.config/dotfiles";

    cp "${DF_ROOT_DIR}/setup/config.sh" "${HOME}/.config/dotfiles/config.sh";
    if [ -f "${HOME}/.dotfiles" ]; then
        cat "${HOME}/.dotfiles" >> "${HOME}/.config/dotfiles/config.sh" && rm "${HOME}/.dotfiles";
    fi
fi

while read -r shell type name remote source; do
    echo "${shell}" | grep -q '^#' && continue;
    [ -d "${DF_ROOT_DIR}/plugins/${name}" ] && continue;

    if [ "${type}" != 'git' ]; then
        echo "plugin type not supported: '${type}'" >&2;
        continue;
    fi

    echo "installing '${name}' into plugins/${name}...";
    git clone -q "${remote}" "${DF_ROOT_DIR}/plugins/${name}";
    echo ". '${DF_ROOT_DIR}/plugins/${name}/${source}';" >> "${DF_ROOT_DIR}/plugins/${shell}.sh";
done < "${DF_ROOT_DIR}/setup/plugins.txt";

cur_shell="$(ps l -p $$ | tail -n1 | awk '{print $13}' | sed 's/^-//')";
if [ -f "${DF_ROOT_DIR}/shells/${cur_shell}/rc.sh" ]; then
    echo "sourcing '${DF_ROOT_DIR}/shells/${cur_shell}/rc.sh'...";
    . "${DF_ROOT_DIR}/shells/${cur_shell}/rc.sh";
fi
