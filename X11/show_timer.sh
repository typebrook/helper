#! /bin/sh

origin="$(xdotool getactivewindow)"
export origin

# If --context is set, apply exit command and different color
if echo "$@" | grep -qs '\--context'; then
  COMMAND_EXIT='~/helper/bin/task/context ${count}s'
  export COLOR=33
fi

# If timer is set, focus to it and exit
xdotool search --name "TIMER" windowactivate && exit 0

# Add new window for a timer
# Use SIGINT to toggle each mode
# Use xdotool to reactivate original window user focus
# After timer is closed or finished, append time into context file
alacritty --title TIMER --hold      \
  -o window.dimensions.columns=8 	\
  -o window.dimensions.lines=1 	    \
  -o window.position.x=-0		    \
  -o window.position.y=0		    \
  -o window.opacity=0.6		        \
  -o font.size=40 	                \
  -e ~/helper/bin/unix/timer.sh \
        SIGINT \
        "xdotool windowactivate $origin" \
        "$COMMAND_EXIT"
