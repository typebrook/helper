#! /bin/bash
# Ref: https://superuser.com/questions/611538/611582#611582

SIGNAL=${1:-SIGTERM}

# If SIGNAL is received, switch to next display
trap 'next_display' "$SIGNAL"
trap 'toggle_timer' SIGTSTP
# Do not print "^C" when SIGINT caught
stty -ctlecho

# Hide the cursor
tput civis

display_list=(STOPWATCH COUNTDOWN PERIOD)
export DISPLAY=0

next_display() {
  export DISPLAY=$(( ("$DISPLAY" + 1) %${#display_list[@]} ))
}

export stop=0
toggle_timer() {
  export stop=$(( ("$stop" + 1) %2 ))
}

# Wait user input
read -p '? ' -r input

# Modify input to fit the format that `date` can read
# s -> sec
# m -> min
# h -> hour
[[ "$input" =~ s && ! "$input" =~ sec  ]] && input="$(sed s/s/sec/  <<<"$input")"
[[ "$input" =~ m && ! "$input" =~ min  ]] && input="$(sed s/m/min/  <<<"$input")"
[[ "$input" =~ h && ! "$input" =~ hour ]] && input="$(sed s/h/hour/ <<<"$input")"

# seconds user set
SET=$(( $(date +%s -d "$input") - $(date +%s) ))
# seconds pass
count=0

timer() {
  start=$(date +%s)
  count_from=$count

  while [ $count -lt $SET ]; do

    # If signal for stop is receive, stop counting
    [ $stop = 1 ] && sleep 0.3 && break

    count=$(( count_from + $(date +%s) - start ))
    case ${display_list[$DISPLAY]} in
      STOPWATCH)
        printf '%s\r' "$(date -u -d @$count +%H:%M:%S)"
        ;;
      COUNTDOWN)
        printf '%s\r' "$(date -u -d @$((SET - count)) +%H:%M:%S)"
        ;;
      PERIOD)
        printf '%s\r' "$(date -u -d @$SET +%H:%M:%S)"
        ;;
    esac

    sleep 0.3
  done
}

while [ $count -lt $SET ]; do
  [ $stop = true ] && sleep 0.3 && continue
  timer
done

# Print bold red text of time that user set
printf "\e[1;31m%s" "$(date -u -d "@$SET" +%H:%M:%S)"
