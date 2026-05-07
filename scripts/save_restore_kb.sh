#!/bin/sh

case "$1" in
  pre)
    # Runs before suspend/hibernate
	output=$(asusctl -k)

	# Extract the brightness value (last word of the relevant line)
	brightness=$(echo "$output" | grep "Current keyboard led brightness:" | awk '{print $NF}')

	# Save the brightness value to the temporary file
	echo "$brightness" > /tmp/kb

	asusctl -k off
    ;;
  post)
    # Runs after resume/wake
		# Default to "Off" if the file doesn't exist or is empty
		kb_brightness="Off"
		if [ -s /tmp/kb ]; then
		    kb_brightness=$(cat /tmp/kb)
		fi

		# Call asusctl to set the brightness
		asusctl -k "$kb_brightness"

    ;;
esac