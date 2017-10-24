#!/bin/bash

systemctl --user import-environment DISPLAY XAUTHORITY PATH
dbus-update-activation-environment DISPLAY XAUTHORITY PATH

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

services_to_start=(
    mpd mpdscribble pulseaudio fcitx battery-monitor xresources
    tmux urxvtd xinput-disable@yubikey xinput-disable@touchscreen
    xinput-disable@'touch controller' xinput-disable@trackpoint synclient
    vboxclient no-dpms no-screensaver
)

if [[ $USER == cdown || $USER == chris ]]; then
    services_to_start+=(prompter)
fi

for service in "${services_to_start[@]}"; do
    systemctl --user start "$service"
done

if [[ "$USER" == chris ]] || [[ $USER == cdown ]]; then
    {
        firefox &
        while ! urxvtc -title dev; do :; done
        start-irssis
        start-mutts
    } &
fi

exec "${WM:-dwm}" > "/tmp/dwm-$USER.log" 2>&1
