xset +fp /usr/share/fonts/local
xset fp rehash

autocutsel -f
autocutsel -f -s PRIMARY

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

urxvtd -q -o -f

exec dbus-launch --exit-with-session dwm
