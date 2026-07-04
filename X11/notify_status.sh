#! /bin/bash

capacity=$(cat ${POWER_CAPACITY:-/sys/class/power_supply/CMB0/capacity})
capacity=${capacity}${capacity:+%}

notify-send -t 2000 "$(date +%H:%M)		${capacity}"
