# We need this to launch dbus properly
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# We use terminus, which is (on Arch Linux) stored in a font path that is not
# hashed by default
xset +fp /usr/share/fonts/local
xset fp rehash

# Only launch a user instance of systemd if one isn't already running
( pgrep -u "$EUID" -x systemd >/dev/null 2>&1 || systemd --user & ) &

exec i3 >"/tmp/i3.log" 2>&1
