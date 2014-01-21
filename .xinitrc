xset +fp /usr/share/fonts/local
xset fp rehash

autocutsel &
autocutsel -s PRIMARY &

systemctl --user start mpd
systemctl --user start mpdscribble

urxvtd -q -o &

exec dbus-launch --exit-with-session dwm
