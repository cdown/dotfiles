xset +fp /usr/share/fonts/local
xset fp rehash

setxkbmap -option caps:none

# Office projector
#xrandr --output VGA1 --right-of LVDS1 --auto

# Vertical side monitor
#xrandr --output VGA1 --right-of LVDS1 --auto --rotate left

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

systemctl --user start mpd &
systemctl --user start mpdscribble &

systemctl --user start urxvtd@"$DISPLAY" &

systemctl --user start offlineimap.timer &

fcitx &

exec dbus-launch --exit-with-session dwm
