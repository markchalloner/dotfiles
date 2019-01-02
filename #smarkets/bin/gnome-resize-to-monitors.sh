#!/bin/bash
dimensions=($(xwininfo -root | awk -F ': +' '/ (Width|Height):/ { print $2 }'))
width=${dimensions[0]}
height=${dimensions[1]}
monitors=$(xrandr | grep " connected " | wc -l)
window="$(xdotool getactivewindow)"
# Unmaximise to allow resizing.
wmctrl -ir "$window" -b remove,maximized_vert,maximized_horz
# Resize.
xdotool windowsize "$window" "$width" "$height"
# Move to 0 0.
xdotool windowmove "$window" "0" "0"
# Ensure window crosses a monitor border.
if [ $monitors -gt 1 ]; then
  xdotool windowmove "$window" "$((100/(monitors-1)))%" "$((100/(monitors-1)))%"
fi
# Ensure window takes all space by resizing to larger.
xdotool windowsize "$window" "$((width*2))" "$((height*2))"
