#! /usr/bin/env bash

BACKLIGHT_DIR=/sys/class/backlight/intel_backlight

CURRENT=$(cat $BACKLIGHT_DIR/brightness)
MAX=$(cat $BACKLIGHT_DIR/max_brightness)

echo " $CURRENT + ( $MAX * ${1/+} )" | \
bc | \
cut -d'.' -f1 >$BACKLIGHT_DIR/brightness
