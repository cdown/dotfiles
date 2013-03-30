# We use terminus, which is (on Arch Linux) stored in a font path that is not
# hashed by default. DON'T background these or programs trying to use this
# font may launch before it is rehashed
xset +fp /usr/share/fonts/local
xset fp rehash

# Turn off the bell
xset b off &

autocutsel -f
autocutsel -f -s PRIMARY

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

urxvtd -q -o -f

exec dbus-launch --exit-with-session dwm
