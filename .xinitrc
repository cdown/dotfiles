# vim: ft=sh

user=$(id -un)

systemctl --user import-environment DISPLAY

export GTK_IM_MODULE=xim
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

type -p VBoxClient-all 2>&1 >/dev/null && VBoxClient-all &

xset +fp /usr/share/fonts/local
xset fp rehash

xrdb -merge ~/.config/x/xresources/base
case $user in
    chris|lin) xrdb -merge ~/.config/x/xresources/"$user"
esac

if ! xrandr | grep -q 'VGA1 disconnected'; then
    xrandr --output VGA1 --right-of LVDS1 --auto
fi

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

urxvtd -q -o &

if [[ "$user" == chris ]]; then
    {
        while ! urxvtc -title dev; do :; done
        urxvtc -title irc -e create-or-attach-tmux-session irc 'while irssi; do :; done'
        urxvtc -title mail -e create-or-attach-tmux-session mail 'while mutt; do :; done'
        google-chrome-stable --high-dpi-support=1 --force-device-scale-factor=1 &
    } &
fi

systemctl --user start offlineimap.timer &

fcitx &

# ibus overrides xmodmap after it's run. Since it might take some time to
# start, just launching after it is not enough, we have to wait until it has
# finished setup to run xmodmap.
#
# https://code.google.com/p/ibus/issues/detail?id=1469
{ sleep 5; xmodmap ~/.xmodmap; } &

xbanish -i Mod4 &

exec dbus-launch --exit-with-session dwm
