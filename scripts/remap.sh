#!/bin/sh
# use with /etc/systemd/system/remap-keys.service
# /etc/systemd/system/remap-keys.service;

# evsieve --input /dev/input/event3 grab    \
#         --map yield key:leftctrl key:a  \
#         --output

evsieve --input /dev/input/event3 \
        --hook key:f4 exec-shell="asusctl led-mode -n > /dev/null 2>&1" \
        --hook key:f5 exec-shell="asusctl profile -n  > /dev/null 2>&1"
