#!/bin/bash

systemctl --user import-environment DISPLAY

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# The Arch-specific FT2_SUBPIXEL_HINTING has been removed in freetype2-2.7-2.
export FREETYPE_PROPERTIES=truetype:interpreter-version=40

declare -A mutts
mutts=(
    [personal]=chris@chrisdown.name
)

type -p VBoxClient-all >/dev/null 2>&1 && VBoxClient-all &

xset +fp /usr/share/fonts/local
xset fp rehash

xrdb -merge ~/.config/x/xresources/base
personal_config=$HOME/.config/x/xresources/$USER
[[ -f $personal_config ]] && xrdb -merge "$personal_config"

pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &

urxvtd -q -o &

if [[ "$USER" == chris ]] || [[ $USER == cdown ]]; then
    {
        while ! urxvtc -title dev; do :; done
        for dir in ~/.irssi/*; do
            irc_type=${dir##*/}
            urxvtc -title irc -e create-or-attach-tmux-session irc-"$irc_type" \
                "while irssi --home=\"$dir\"; do :; done"
        done

        for account_type in "${!mutts[@]}"; do
            email="${mutts[$account_type]}"
            maildir="$HOME/Mail/${account_type^}"
            if [[ -r ~/.config/mutt/accounts/"$email" ]]; then
                urxvtc -title mail -e create-or-attach-tmux-session \
                    "mail-$account_type" \
                    "EMAIL='$email' NOTMUCH_BASENAME='$account_type' MAILDIR='$maildir' start-mutt"
            fi
        done

        firefox &
    } &
fi

systemctl --user start mbsync.service

fcitx &

xbanish -i Mod4 &
battery-monitor &

if type synclient >/dev/null 2>&1; then
    # 2 finger click = right click
    synclient \
        TapButton2=3 VertScrollDelta=350 HorizScrollDelta=350 \
        AccelFactor=0 MinSpeed=1.4 HorizTwoFingerScroll=1 PalmDetect=1 \
        TapButton1=1
fi

# Interim solution until this gets set up with systemd
for scontrol in Master PCM; do
    amixer -q sset "$scontrol" unmute
    amixer -q sset "$scontrol" 100%
done

xinput-toggle -r yubikey -d &

# TODO: this is a temporary hack while I have this X1 Carbon laptop rented out,
# if this lasts more than a couple of weeks I should make an xkb layout mod
# for this
if grep -q 'X1 Carbon 2nd' /sys/devices/virtual/dmi/id/product_version; then
    while sleep 5; do xmodmap ~/.config/xmodmap/x1-carbon; done & 
fi

exec dwm > "/tmp/dwm-$USER.log" 2>&1
