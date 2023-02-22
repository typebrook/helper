#! /bin/bash
# Ref: https://superuser.com/questions/611538/611582#611582

# If user type '^C', then use SIGINT to toggle the display
trap '[ "$SHOWGIVEN" = yes ] && SHOWGIVEN= || SHOWGIVEN=yes' SIGINT
# Do not print "^C" when SIGINT caught
stty -ctlecho

# Hide the cursor
tput civis

# Wait user input
read -p '? ' input

# Modify input to fit the format that `date` can read
# s -> sec
# m -> min
# h -> hour
[[ "$input" =~ s && ! "$input" =~ sec  ]] && input="$(sed s/s/sec/  <<<"$input")"
[[ "$input" =~ m && ! "$input" =~ min  ]] && input="$(sed s/m/min/  <<<"$input")"
[[ "$input" =~ h && ! "$input" =~ hour ]] && input="$(sed s/h/hour/ <<<"$input")"

time=0
start=$(date +%s)
given=$(date +%s -d "$input")
stop=$(( $given - $start ))
while [ $time -ne $stop ]; do
    time="$(( $(date +%s) - $start ))"
    if [ -z "$SHOWGIVEN" ]; then
        printf '%s\r' "$(date -u -d @$time +%H:%M:%S)"
    else 
        printf '%s\r' "$(date -u -d @$stop +%H:%M:%S)"
    fi
    sleep 0.3
done

printf "\e[1;31m$(date -u -d "@$time" +%H:%M:%S)"
