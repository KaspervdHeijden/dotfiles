# Wallpaper rotator

To use this, install this in a service or as a cronjob with `@reboot`

## To run as a service:

```sh
# 1. make sure path exist first
[ -d ~/.config/systemd/user ] || mkdir -p ~/.config/systemd/user;

# 2. install the service file while making sure path is correct in the service file
sed "s#\$DF_ROOT_DIR#${DF_ROOT_DIR}#; s#\$HOME#${HOME}#" ./scripts/wallpaper-rotator/wallpaper-rotator.service > ~/.config/systemd/user/wallpaper-rotator.service;

# 3. optionally edit the file to add a timeout, or to add/change the wallpaper paths
vim ~/.config/systemd/user/wallpaper-rotator.service;

# 4. start service
systemctl start wallpaper-rotator --user;

# 5. optionally inspect
systemctl status wallpaper-rotator --user;
```

