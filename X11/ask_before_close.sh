#! /bin/sh

current_window=$(xdotool getactivewindow)

if [ $(xdotool getwindowclassname $current_window) = CONFIRM_BEFORE_CLOSE ]; then
  zenity --question --text "Are you sure you want to close this window?" || \
  exit 1
fi

xdotool windowkill $current_window
