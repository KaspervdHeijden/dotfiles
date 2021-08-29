#!/usr/bin/env sh

filename="${HOME}/.config/dotfiles/plugins.txt";
if [ ! -f "${filename}" ]; then
    filename="${DF_ROOT_DIR}/setup/plugins.txt";

    if [ ! -f "${filename}" ]; then
        echo 'could not load plugin files' >&2;
        exit 3;
    fi
fi

plugin_dir="${DF_PLUGIN_DIR:-${DF_ROOT_DIR}/plugins}";

rm "${DF_ROOT_DIR}"/plugins/*.sh >/dev/null 2>/dev/null;
echo 'updating plugins...';

while read -r intended_shell plugin_type plugin_name remote_uri file_to_source; do
    echo "${intended_shell}" | grep -q '^ *#' && continue;

    if [ -z "${plugin_name}" ]; then
        echo 'plugin name not set' >&2;
        continue;
    fi

    if [ "${plugin_type}" != 'git' ]; then
        echo "  -> plugin type ('${plugin_type}') not supported for '${plugin_name}'" >&2;
        continue;
    fi

    if [ -d "${plugin_dir}/${plugin_name}" ]; then
        echo "  -> updating ${plugin_name}";

        if ! (cd "${plugin_dir}/${plugin_name}" && git pull -q --ff-only); then
            echo "could not update ${plugin_name} from ${remote_uri}i" >&2;
            continue;
        fi
    else
        echo "  -> installing ${plugin_name}";

        if ! git clone -q "${remote_uri}" "${plugin_dir}/${plugin_name}"; then
            echo "could not clone ${plugin_name} from ${remote_uri}i" >&2;
            continue;
        fi
    fi

    echo ". '${plugin_dir}/${plugin_name}/${file_to_source}';" >> "${DF_ROOT_DIR}/plugins/${intended_shell}.sh";
done < "${filename}";
