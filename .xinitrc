#!/bin/bash

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export CLUTTER_PAINT=disable-clipped-redraws:disable-culling

to_export=(DISPLAY XAUTHORITY PATH GTK_IM_MODULE QT_IM_MODULE XMODIFIERS)

systemctl --user import-environment "${to_export[@]}"
dbus-update-activation-environment "${to_export[@]}"

services_to_start=(
    pulseaudio fcitx battery-notify xresources
    tmux xinput-disable@yubikey xinput-disable@touchscreen
    xinput-disable@ELAN901C xinput-disable@screen xinput-disable@NVTK0603
    synclient no-dpms no-screensaver clipmenud upgrade-reminder.timer
    psi-notify xob mpd mpd-mpris
)

if [[ $USER == cdown || $USER == chris ]] && [[ -z $WM ]]; then
    services_to_start+=(
        irssi mutt mpdscribble inbox-reminder.timer mute-all-mics
    )
fi

if [[ $USER == lin ]]; then
    services_to_start+=(eyebreak)
fi

for service in "${services_to_start[@]}"; do
    systemctl --user restart "$service"
done

while sleep 0.5; do
    "${WM:-dwm}" >> "/tmp/dwm-$USER.log" 2>&1
    hash -r  # in case we now have a new one in /usr/local/bin, for example
done
