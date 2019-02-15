#!/bin/bash

sudo service bluetooth restart
while ! xinput list "Mark's Trackpad" > /dev/null 2>&1; do
	sleep 1
done
xinput set-prop "Mark's Trackpad" 'Coordinate Transformation Matrix' -1 0 1 0 -1 1 0 0 1
xinput set-prop "Mark's Trackpad" 'libinput Natural Scrolling Enabled' 0
