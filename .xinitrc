# We need this to launch dbus properly
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# We use terminus, which is (on Arch Linux) stored in a font path that is not
# hashed by default. DON'T background these or programs trying to use this
# font may launch before it is rehashed
xset +fp /usr/share/fonts/local
xset fp rehash

# Turn off the bell
xset b off &

# Only launch a user instance of systemd if one isn't already running
( pgrep -u "$EUID" -x systemd >/dev/null 2>&1 || systemd --user & ) &

exec i3 >"/tmp/i3.log" 2>&1
