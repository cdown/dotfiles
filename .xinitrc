xset +fp /usr/share/fonts/local
xset fp rehash

setxkbmap -option caps:none

# Office projector
#xrandr --output VGA1 --right-of LVDS1 --auto

# Vertical side monitor
#xrandr --output VGA1 --right-of LVDS1 --auto --rotate left

systemctl --user start mpd
systemctl --user start mpdscribble

systemctl --user start urxvtd@"$DISPLAY"

systemctl --user start offlineimap.timer

exec dbus-launch --exit-with-session dwm
