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
    clipmenud prompter
)
for service in "${services_to_start[@]}"; do
    systemctl --user start "$service"
done

type -p VBoxClient-all >/dev/null 2>&1 && VBoxClient-all &

urxvtd -q -o &

if [[ "$USER" == chris ]] || [[ $USER == cdown ]]; then
    {
        firefox &
        while ! urxvtc -title dev; do :; done
        start-irssis
        start-mutts
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

# Disable screen dimming
xset dpms 0 0 0
xset s off

exec dwm > "/tmp/dwm-$USER.log" 2>&1
