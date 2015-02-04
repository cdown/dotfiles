export GTK_IM_MODULE=xim
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

type -p VBoxClient-all 2>&1 >/dev/null && VBoxClient-all &

xset +fp /usr/share/fonts/local
xset fp rehash

xmodmap ~/.xmodmap

setxkbmap -option ctrl:nocaps

if ! xrandr | grep -q 'VGA1 disconnected'; then
    xrandr --output VGA1 --right-of LVDS1 --auto
fi

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

urxvtd -q -o &

systemctl --user start offlineimap.timer &

fcitx &

exec dbus-launch --exit-with-session dwm
