#!/bin/bash

# Check the /sys/class/backlight directory to find your backlight (bl) device and use that.
bl_device=/sys/class/backlight/nvidia_wmi_ec_backlight

# Reduce brightness in steps of 20.
newbrightness=$(($(cat $bl_device/brightness)-10))

# Set a minimum brightness of 10 to prevent the screen from going completely dark.
# Ensure the `brightness` file has write permission (use udev)
[[ $newbrightness -le 10 ]] || echo $newbrightness > $bl_device/brightness

