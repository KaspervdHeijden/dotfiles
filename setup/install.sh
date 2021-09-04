#!/usr/bin/env sh

root_dir="$(
    script_dir="$(lsof -p $$ 2>/dev/null | awk '/install.sh$/ {print $NF}' | sed 's#/install.sh##')";

    if [ -n "${script_dir}" ]; then
        echo "$(dirname "${script_dir}")";
    elif [ -n "${BASH_SOURCE:-}" ]; then
        echo "$(dirname "$(dirname "${BASH_SOURCE}")")";
    elif [ -f "${0}" ]; then
        echo "$(dirname "${0}")";
    fi
)";

if [ ! -d "${root_dir}" ]; then
    echo 'could not determine root directory' >&2;
    return 3;
fi

echo "configuring dotfiles from ${root_dir}...";
for shell_name in $(cd "${root_dir}/shells"; ls -d *); do
    [ ! -f "${root_dir}/shells/${shell_name}/rc.sh" ] && continue;

    file="${HOME}/.${shell_name}rc";
    if grep -q "${root_dir}/shells/${shell_name}/rc.sh" "${file}" 2>/dev/null; then
        echo "  -> config for ${shell_name} already present in ${file}";
        continue;
    fi

    echo "  -> adding config for ${shell_name} to ${file}";

    [ -s "${file}" ] && echo '' >> "${file}";
    echo '# include dotfiles' >> "${file}";
    echo ". '${root_dir}/shells/${shell_name}/rc.sh';" >> "${file}";
done;

(
    cd "${root_dir}" || return 1;
    git config --local dotfiles.checkDefaultBranch 0;
    git config --local dotfiles.checkFork 0;
);

mkdir -p "${HOME}/.config/dotfiles";
[ ! -f "${HOME}/.config/dotfiles/config.sh" ] && cp "${root_dir}/setup/config.sh" "${HOME}/.config/dotfiles/config.sh";

"${root_dir}/setup/plugins.sh";

cur_shell="$(ps -p $$ -o args= | sed 's/^-//')";
if [ -f "${root_dir}/shells/${cur_shell}/rc.sh" ]; then
    echo "sourcing '${root_dir}/shells/${cur_shell}/rc.sh'...";
    . "${root_dir}/shells/${cur_shell}/rc.sh";
fi
