#!/bin/bash

# Get devices where wakeup enabled.
device_range=$(grep -l enabled /sys/bus/usb/devices/*/power/wakeup | sed 's#/sys/bus/usb/devices/\([^/]\+\)/power/wakeup#\1#g' | tr '-' ' ')
# Login.
sudo -v
# Disable device wakeup.
while read device_id; do
  # Set device wakeup to disabled.
  echo -n "Setting usb${device_id} to "
  echo "disabled" | sudo tee /sys/bus/usb/devices/usb${device_id}/power/wakeup
done <<< "$(seq $device_range)"
