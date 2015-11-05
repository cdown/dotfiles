#!/bin/bash

systemctl --user import-environment DISPLAY

export GTK_IM_MODULE=xim
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

declare -A mutts
mutts=(
    [personal]=chris@chrisdown.name
)

type -p VBoxClient-all >/dev/null 2>&1 && VBoxClient-all &

xset +fp /usr/share/fonts/local
xset fp rehash

xrdb -merge ~/.config/x/xresources/base
case $USER in
    chris|lin) xrdb -merge ~/.config/x/xresources/"$USER"
esac

urxvtd -q -o &

if [[ "$USER" == chris ]]; then
    {
        while ! urxvtc -title dev; do :; done
        for dir in ~/.irssi/*; do
            irc_type=${dir##*/}
            urxvtc -title irc -e create-or-attach-tmux-session irc-"$irc_type" \
                "while irssi --home=\"$dir\"; do :; done"
        done

        for account_type in "${!mutts[@]}"; do
            email="${mutts[$account_type]}"
            if [[ -r ~/.config/mutt/accounts/"$email" ]]; then
                urxvtc -title mail -e create-or-attach-tmux-session \
                    "mail-$account_type" 'while mutt; do :; done'
            fi
        done

        google-chrome-stable --high-dpi-support=1 --force-device-scale-factor=1 &
    } &
fi

systemctl --user start offlineimap.timer &

fcitx &

# ibus overrides xmodmap after it's run. Since it might take some time to
# start, just launching after it is not enough, we have to wait until it has
# finished setup to run xmodmap.
#
# It seems ibus also decides to override it a while after starting, so this
# needs to get run in a loop... sigh.
#
# https://code.google.com/p/ibus/issues/detail?id=1469
{ while sleep 5; do xmodmap ~/.xmodmap; done } &

xbanish -i Mod4 &
clipmenud &

exec dbus-launch --exit-with-session dwm
