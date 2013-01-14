if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

xset +fp /usr/share/fonts/local
xset fp rehash

autocutsel -fork &
autocutsel -fork -selection PRIMARY &

systemd --user &
exec i3 >"/tmp/i3-$$.log" 2>&1
