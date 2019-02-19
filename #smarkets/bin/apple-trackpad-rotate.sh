#!/bin/bash

export USER=${USER:-mark}
export XAUTHORITY=${XAUTHORITY:-/run/user/$(id -u "$USER")/gdm/Xauthority}
export DISPLAY=${DISPLAY:-:0}

LOG="/tmp/apple-trackpad.log"

trackpad_names=("MarksTrackpad1")

touch $LOG
echo "========================================" >> $LOG
date >> $LOG
echo "Running $0 $1." >> $LOG
printenv >> $LOG
for i in {1..10}; do
    count=0
    echo "Xauthority: $XAUTHORITY" >> "$LOG"
    echo "Xinput devices: " >> $LOG
    xinput >> $LOG
    for trackpad_name in "${trackpad_names[@]}"; do
        if xinput list "$trackpad_name" > /dev/null 2>&1; then
            count=$((count+1))
        fi
    done
    if [ "$count" -ge "${#trackpad_names[@]}" ]; then
        break
    fi
    sleep 1
done

echo here >> $LOG

xinput >> $LOG

for trackpad_name in "${trackpad_names[@]}"; do
    if [ "$1" == "reset" ]; then
      xinput set-prop "$trackpad_name" 'Coordinate Transformation Matrix'  0 0 0 0  0 0 0 0 0 >> $LOG
      xinput set-prop "$trackpad_name" 'libinput Natural Scrolling Enabled' 1 >> $LOG
    else
      xinput set-prop "$trackpad_name" 'Coordinate Transformation Matrix' -1 0 1 0 -1 1 0 0 1 >> $LOG
      xinput set-prop "$trackpad_name" 'libinput Natural Scrolling Enabled' 0 >> $LOG
    fi
done
