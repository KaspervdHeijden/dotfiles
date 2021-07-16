#!/usr/bin/env sh

sed -i 's#$DOTFILES_DIR#$DF_ROOT_DIR#g' "${HOME}/.bashrc";
sed -i 's#$DOTFILES_DIR#$DF_ROOT_DIR#g' "${HOME}/.zshrc";

for shell in bash zsh; do
    grep -v '$DF_ROOT_DIR' "${HOME}/.${shell}rc" > "${HOME}/tmp" && mv "${HOME}/tmp" "${HOME}/.${shell}rc";

    if ! grep -q "${DF_ROOT_DIR}/shells/${shell}/rc.sh" "${HOME}/.${shell}rc"; then
        echo ". '${DF_ROOT_DIR}/shells/${shell}/rc.sh';" >> "${HOME}/.${shell}rc";
    fi
done;

sed -i 's#$DF_REPO_DIRS#$DF_CDS_REPO_DIRS#g; s#$DF_MAX_DEPTH#$DF_CDS_MAX_DEPTH#g' "${HOME}/.config/dotfiles/config.sh";
