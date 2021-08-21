DF_ROOT_DIR="$(
    script_dir="$(lsof -p $$ | awk '/install.sh$/ { print $NF; }' | sed 's#/install.sh##')";

    if [ -n "${script_dir}" ]; then
        echo "$(dirname "${script_dir}")";
    elif [ -n "${BASH_SOURCE}" ]; then
        echo "$(dirname "$(dirname "${BASH_SOURCE}")")";
    elif [ -d "${0}" ]; then
        echo "$(dirname "${0}")";
    fi
)";

if [ ! -d "${DF_ROOT_DIR}" ]; then
    echo 'could not determine root directory' >&2;
    return 3;
fi

echo "configuring dotfiles from ${DF_ROOT_DIR}...";
for shell_name in $(cd "${DF_ROOT_DIR}/shells"; ls -d *); do
    [ ! -f "${DF_ROOT_DIR}/shells/${shell_name}/rc.sh" ] && continue;

    file="${HOME}/.${shell_name}rc";
    if grep -q "${DF_ROOT_DIR}/shells/${shell_name}/rc.sh" "${file}" 2>/dev/null; then
        echo "  -> config for ${shell_name} already present in ${file}";
        continue;
    fi

    echo "  -> adding config for ${shell_name} to ${file}";

    [ -s "${file}" ] && echo '' >> "${file}";
    echo '# include dotfiles' >> "${file}";
    echo ". '${DF_ROOT_DIR}/shells/${shell_name}/rc.sh';" >> "${file}";
done;

(
    cd "${DF_ROOT_DIR}" || return 1;
    git config --local dotfiles.checkDefaultBranch 0;
    git config --local dotfiles.checkFork 0;
);

mkdir -p "${HOME}/.config/dotfiles";
[ ! -f "${HOME}/.config/dotfiles/config.sh" ] && cp "${DF_ROOT_DIR}/setup/config.sh" "${HOME}/.config/dotfiles/config.sh";

"${DF_ROOT_DIR}/setup/plugins.sh" install;

cur_shell="$(ps -p $$ -o args=)";
if [ -f "${DF_ROOT_DIR}/shells/${cur_shell}/rc.sh" ]; then
    echo "sourcing '${DF_ROOT_DIR}/shells/${cur_shell}/rc.sh'...";
    . "${DF_ROOT_DIR}/shells/${cur_shell}/rc.sh";
fi
