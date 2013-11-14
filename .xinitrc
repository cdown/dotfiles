wmname LG3D &

xset +fp /usr/share/fonts/local
xset fp rehash

xset b off

autocutsel &
autocutsel -s PRIMARY &

dunst &

xautolock -time 1 -locker 'i3lock -udc 000000' &

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

urxvtd -q -o &

exec dbus-launch --exit-with-session dwm
