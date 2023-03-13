#! /bin/sh

xdotool set_window --name "$1" --class CONFIRM_BEFORE_CLOSE "$(xdotool getactivewindow)"
