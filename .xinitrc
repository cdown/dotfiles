# vim: ft=sh

user=$(id -un)

for file in /etc/X11/xinit/xinitrc.d/*; do
    [[ -f $file ]] && . "$file"
done

systemctl --user import-environment DISPLAY

export GTK_IM_MODULE=xim
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

type -p VBoxClient-all 2>&1 >/dev/null && VBoxClient-all &

xset +fp /usr/share/fonts/local
xset fp rehash

case $user in
    chris|lin) xrdb -merge ~/.config/x/xresources/"$user"
esac

xmodmap ~/.xmodmap

if ! xrandr | grep -q 'VGA1 disconnected'; then
    xrandr --output VGA1 --right-of LVDS1 --auto
fi

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

urxvtd -q -o &

if [[ "$user" == chris ]]; then
    {
        sleep 3
        urxvtc -title dev
        urxvtc -title mail -e create-or-attach-tmux-session mail mutt
        urxvtc -title irc -e create-or-attach-tmux-session irc irssi
        google-chrome-stable &
    } &
fi

systemctl --user start offlineimap.timer &

fcitx &

exec dbus-launch --exit-with-session dwm
