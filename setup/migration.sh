#!/usr/bin/env sh

sed -i 's#$DOTFILES_DIR#$DF_ROOT_DIR#g' ~/.bashrc;
sed -i 's#$DOTFILES_DIR#$DF_ROOT_DIR#g' ~/.zshrc;

sed -i 's#$DF_REPO_DIRS#$DF_CDS_REPO_DIRS#g; s#$DF_MAX_DEPTH#$DF_CDS_MAX_DEPTH#g' ~/.config/dotfiles/config.sh;

