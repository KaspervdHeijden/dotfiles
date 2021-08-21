#!/usr/bin/env sh
action="${1}";

while read -r shell plugin_type name remote source; do
    echo "${shell}" | grep -q '^ *#' && continue;

    if [ "${plugin_type}" != 'git' ]; then
        echo "plugin type not supported: '${plugin_type}'" >&2;
        continue;
    fi

    case "${action}" in
        install)
            [ -d "${DF_ROOT_DIR}/plugins/${name}" ] && continue;

            echo "installing '${name}' into plugins/${name}...";
            git clone -q "${remote}" "${DF_ROOT_DIR}/plugins/${name}";
            echo ". '${DF_ROOT_DIR}/plugins/${name}/${source}';" >> "${DF_ROOT_DIR}/plugins/${shell}.sh";
        ;;

        update)
            if [ ! -d "${DF_ROOT_DIR}/plugins/${name}" ]; then
                echo "plugin not installed: '${name}'" >&2;
                continue;
            fi

            echo "updating '${name}'...";
            (cd "${DF_ROOT_DIR}/plugins/${name}" && git pull -q -ff);
        ;;

        *)
            echo "unrecognized action '${action}'" >&2;
            exit 3;
        ;;
    esac
done < "${DF_ROOT_DIR}/setup/plugins.txt";
