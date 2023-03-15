#! /bin/sh

xdotool set_window --name "@${1##@}" "$(xdotool getactivewindow)"
