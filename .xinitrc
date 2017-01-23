#!/bin/bash

systemctl --user import-environment DISPLAY XAUTHORITY PATH
dbus-update-activation-environment DISPLAY XAUTHORITY PATH

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# The Arch-specific FT2_SUBPIXEL_HINTING has been removed in freetype2-2.7-2.
export FREETYPE_PROPERTIES=truetype:interpreter-version=40

services_to_start=(
    mpd mpdscribble pulseaudio fcitx xbanish battery-monitor xresources
    clipmenud
)
for service in "${services_to_start[@]}"; do
    systemctl --user start "$service"
done

declare -A mutts
mutts=(
    [personal]=chris@chrisdown.name
)

type -p VBoxClient-all >/dev/null 2>&1 && VBoxClient-all &

urxvtd -q -o &

if [[ "$USER" == chris ]] || [[ $USER == cdown ]]; then
    {
        while ! urxvtc -title dev; do :; done
        for dir in ~/.irssi/*; do
            irc_type=${dir##*/}
            urxvtc -title irc -e create-or-attach-tmux-session irc-"$irc_type" \
                "while :; do irssi --home=\"$dir\"; done"
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

if type synclient >/dev/null 2>&1; then
    # 2 finger click = right click
    synclient \
        TapButton2=3 VertScrollDelta=350 HorizScrollDelta=350 \
        AccelFactor=0 MinSpeed=1.4 HorizTwoFingerScroll=1 PalmDetect=1 \
        TapButton1=1
fi

for device in yubikey touchscreen 'touch controller' trackpoint; do
    xinput-toggle -r "$device" -d &
done

# TODO: this is a temporary hack while I have this X1 Carbon laptop rented out,
# if this lasts more than a couple of weeks I should make an xkb layout mod
# for this
if grep -q 'X1 Carbon 2nd' /sys/devices/virtual/dmi/id/product_version; then
    while sleep 5; do xmodmap ~/.config/xmodmap/x1-carbon; done &
fi

# Swap cmd <-> alt on Apple keyboards + Noam's keyboard
apple_keyboard=05ac:0250
noam_keyboard=04d9:0269
for id in "$apple_keyboard" "$noam_keyboard"; do
    if lsusb -d "$id" >/dev/null 2>&1; then
        while sleep 5; do xmodmap ~/.config/xmodmap/cmdalt; done &
        break
    fi
done

# Disable screen dimming
xset dpms 0 0 0
xset s off

exec dwm > "/tmp/dwm-$USER.log" 2>&1
