#!/bin/bash

# Check the /sys/class/backlight directory to find your backlight (bl) device and use that.
bl_device=/sys/class/backlight/nvidia_wmi_ec_backlight

# Increase brightness in steps of 20.
newbrightness=$(($(cat $bl_device/brightness)+20))

# Get the maximum brightness from the `max_brightness` file.
# Ensure the `brightness` file has write permission (use udev)
[[ $newbrightness -gt $(cat $bl_device/max_brightness) ]] || echo $newbrightness > $bl_device/brightness


