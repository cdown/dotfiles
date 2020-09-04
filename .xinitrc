#!/bin/bash

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

to_export=(DISPLAY XAUTHORITY PATH GTK_IM_MODULE QT_IM_MODULE XMODIFIERS)

systemctl --user import-environment "${to_export[@]}"
dbus-update-activation-environment "${to_export[@]}"

services_to_start=(
    pulseaudio fcitx battery-monitor.timer xresources
    tmux urxvtd xinput-disable@yubikey xinput-disable@touchscreen
    xinput-disable@screen xinput-disable@trackpoint synclient
    no-dpms no-screensaver clipmenud upgrade-reminder.timer
    redshift-auto psi-notify xob
)

if [[ $USER == cdown || $USER == chris ]] && [[ -z $WM ]]; then
    services_to_start+=(
        prompter irssi mutt mpdscribble inbox-reminder.timer mpd habitual
    )
fi

for service in "${services_to_start[@]}"; do
    systemctl --user restart "$service"
done

while :; do
    "${WM:-dwm}" >> "/tmp/dwm-$USER.log" 2>&1
    hash -r  # in case we now have a new one in /usr/local/bin, for example
done
