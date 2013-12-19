xset +fp /usr/share/fonts/local
xset fp rehash

xset b off

autocutsel &
autocutsel -s PRIMARY &

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

urxvtd -q -o &

exec dbus-launch --exit-with-session dwm
