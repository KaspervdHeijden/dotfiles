#!/usr/bin/env sh

filename="${HOME}/.config/dotfiles/plugins.txt";
if [ ! -f "${filename}" ]; then
    filename="${DF_ROOT_DIR}/setup/plugins.txt";
fi

if [ ! -f "${filename}" ]; then
    echo 'could not load plugin files' >&2;
    exit 3;
fi

action="${1}";
case "${action}" in
    install) echo 'installing plugins...' ;;
    update)  echo 'updating plugins...'   ;;
    *)
        echo "unrecognized action '${action}'" >&2;
        exit 4;
    ;;
esac

while read -r intended_shell plugin_type plugin_name remote_uri file_to_source; do
    echo "${intended_shell}" | grep -q '^ *#' && continue;

    if [ "${plugin_type}" != 'git' ]; then
        echo "  -> plugin type ('${plugin_type}') not supported for '${plugin_name}'" >&2;
        continue;
    fi

    case "${action}" in
        install)
            if [ -d "${DF_ROOT_DIR}/plugins/${plugin_name}" ]; then
                echo "  -> plugin ${plugin_name} already installed";
                continue;
            fi

            echo "  -> installing ${plugin_name}";
            git clone -q "${remote_uri}" "${DF_ROOT_DIR}/plugins/${plugin_name}";

            line=". '${DF_ROOT_DIR}/plugins/${plugin_name}/${file_to_source}';";
            if ! grep -q "${line}" "${DF_ROOT_DIR}/plugins/${intended_shell}.sh" 2>/dev/null; then
                echo "${line}" >> "${DF_ROOT_DIR}/plugins/${intended_shell}.sh";
            fi
        ;;

        update)
            if [ ! -d "${DF_ROOT_DIR}/plugins/${plugin_name}" ]; then
                echo "  -> plugin ${plugin_name} not installed" >&2;
                continue;
            fi

            echo "  -> updating ${plugin_name}";
            (cd "${DF_ROOT_DIR}/plugins/${plugin_name}" && git pull -q --ff-only);
        ;;
    esac
done < "${filename}";
