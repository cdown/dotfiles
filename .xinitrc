#!/bin/bash

systemctl --user import-environment DISPLAY

export GTK_IM_MODULE=fcitx
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

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

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
                    "mail-$account_type" \
                    "EMAIL=\"$email\" NOTMUCH_BASENAME=\"$account_type\" start-mutt"
            fi
        done

        google-chrome-stable --high-dpi-support=1 --force-device-scale-factor=1 &
    } &
fi

systemctl --user start mbsync.service

fcitx &

xbanish -i Mod4 &

if type synclient >/dev/null 2>&1; then
    # 2 finger click = right click
    synclient \
        TapButton2=3 VertScrollDelta=350 HorizScrollDelta=350 \
        AccelFactor=0 MinSpeed=1.4 HorizTwoFingerScroll=1 PalmDetect=1
fi

# Interim solution until this gets set up with systemd
for scontrol in Master PCM; do
    amixer -q sset "$scontrol" unmute
    amixer -q sset "$scontrol" 100%
done

exec dbus-launch --exit-with-session dwm > "/tmp/dwm-$USER.log" 2>&1
