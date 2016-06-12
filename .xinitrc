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

# ibus overrides xmodmap after it's run. Since it might take some time to
# start, just launching after it is not enough, we have to wait until it has
# finished setup to run xmodmap.
#
# https://code.google.com/p/ibus/issues/detail?id=1469
#
# There's also a bug where this does not persist after USB hotplug, so we run
# in a loop. :-(
(while sleep 10; do xmodmap ~/.xmodmap; done) &

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

# Ideally this should be done in xorg.conf, but for now I want to keep this as
# part of the dotfiles repo. Less hacky ways to be explored later.
#
# Middle button -> Right click
# Middle mouse click -> Middle button (paste)
(while sleep 10; do xinput set-button-map "Kingsis Peripherals Evoluent VerticalMouse 4" 1 3 3 4 5 6 7 8 2 10; done) &

exec dbus-launch --exit-with-session dwm > "/tmp/dwm-$USER.log" 2>&1
