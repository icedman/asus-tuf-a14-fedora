#!/bin/bash

# Run the command and capture its output
output=$(asusctl -k)

# Extract the brightness value (last word of the relevant line)
brightness=$(echo "$output" | grep "Current keyboard led brightness:" | awk '{print $NF}')

# Save the brightness value to the temporary file
echo "$brightness" > /tmp/kb

