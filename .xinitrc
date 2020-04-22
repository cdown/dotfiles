#!/bin/bash

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

to_export=(DISPLAY XAUTHORITY PATH GTK_IM_MODULE QT_IM_MODULE XMODIFIERS)

systemctl --user import-environment "${to_export[@]}"
dbus-update-activation-environment "${to_export[@]}"

services_to_start=(
    mpd pulseaudio fcitx battery-monitor.timer xresources
    tmux urxvtd xinput-disable@yubikey xinput-disable@touchscreen
    xinput-disable@screen xinput-disable@trackpoint synclient
    no-dpms no-screensaver clipmenud upgrade-reminder.timer
    redshift-auto
)

if [[ $USER == cdown || $USER == chris ]] && [[ -z $WM ]]; then
    services_to_start+=(prompter irssi mutt mpdscribble)
fi

for service in "${services_to_start[@]}"; do
    systemctl --user restart "$service"
done

while :; do
    WM=$(< /tmp/_wm 2>/dev/null)  # allow relaunch with changes
    "${WM:-dwm}" >> "/tmp/dwm-$USER.log" 2>&1
done
