#! /bin/sh

origin="$(xdotool getactivewindow)"
export origin

# If timer is set, focus to it and exit
xdotool search --name "TIMER" windowactivate && exit 0

# Add new window for a timer
# Use SIGINT to toggle each mode
# Use xdotool to reactivate original window user focus
# After timer is closed or finished, append time into context file
alacritty --title TIMER --hold      \
  -o "window.dimensions.columns=8" 	\
  -o "window.dimensions.lines=1" 	\
  -o "window.position.x=-0"		    \
  -o "window.position.y=0"		    \
  -o "window.opacity=0.6"		    \
  -o "font.size=40" 	            \
  -e "$HOME"/helper/bin/unix/timer.sh \
        SIGINT \
        "xdotool windowactivate $origin" \
        '~/helper/bin/task/context_spend_time.sh $count'
