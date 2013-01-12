xset +fp /usr/share/fonts/local
xset fp rehash

autocutsel -fork &
autocutsel -fork -selection PRIMARY &

systemd --user &
exec i3 >"/tmp/i3-$$.log" 2>&1
