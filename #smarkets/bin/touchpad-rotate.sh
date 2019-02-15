#!/bin/bash

if [ "$1" == "reset" ]; then
  xinput set-prop "Mark's Trackpad" 'Coordinate Transformation Matrix'  0 0 0 0  0 0 0 0 0
  xinput set-prop "Mark's Trackpad" 'libinput Natural Scrolling Enabled' 1
else
  xinput set-prop "Mark's Trackpad" 'Coordinate Transformation Matrix' -1 0 1 0 -1 1 0 0 1
  xinput set-prop "Mark's Trackpad" 'libinput Natural Scrolling Enabled' 0
fi
