#! /usr/bin/env bash

BRIGHTNESS=$(xrandr --verbose | grep Brightness: | cut -d' ' -f2)

VALUE=$( echo $BRIGHTNESS $1 | bc )
xrandr --output eDP-1 --brightness $VALUE
