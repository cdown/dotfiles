xset +fp /usr/share/fonts/local
xset fp rehash

# Office projector
#xrandr --output VGA1 --right-of LVDS1 --auto

# Vertical side monitor
#xrandr --output VGA1 --right-of LVDS1 --auto --rotate left

clipmenud &

autocutsel &
autocutsel -s PRIMARY &

systemctl --user start mpd
systemctl --user start mpdscribble

systemctl --user start urxvtd

systemctl --user start offlineimap.timer

exec dbus-launch --exit-with-session dwm
