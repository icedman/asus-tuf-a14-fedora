#!/bin/bash

# Default to "Off" if the file doesn't exist or is empty
kb_brightness="Off"
if [[ -s /tmp/kb ]]; then
    kb_brightness=$(cat /tmp/kb)
fi

# Call asusctl to set the brightness
asusctl -k "$kb_brightness"

