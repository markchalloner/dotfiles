#!/bin/bash

set -euo pipefail

# Get devices where wakeup enabled.
device_ranges=$({ grep -l enabled /sys/bus/usb/devices/*/power/wakeup || true; } | sed 's#/sys/bus/usb/devices/\([^/]\+\)/power/wakeup#\1#g')
# Check if we need to continue.
if [ -z "$device_ranges" ]; then
  echo "No USB devices have wake enabled."
  exit
fi
# Login.
sudo -v
# Disable device wakeup.
while read device_range; do
  # Set device wakeup to disabled.
  echo "Disabling wake on USB device range ${device_range}."
  echo "disabled" | sudo tee /sys/bus/usb/devices/${device_range}/power/wakeup > /dev/null
done <<< "$device_ranges"
