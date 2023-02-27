#! /bin/bash
# Ref: https://superuser.com/questions/611538/611582#611582

SIGNAL=${1:-SIGTERM}

# If SIGNAL is received, switch to next display
trap 'next_display' $SIGNAL
#trap 'toggle_timer' SIGTSTP
# Do not print "^C" when SIGINT caught
stty -ctlecho

# Hide the cursor
tput civis

display_list=(STOPWATCH COUNTDOWN PERIOD)
export DISPLAY=0

next_display() {
  export DISPLAY=$(( ($DISPLAY + 1) %${#display_list[@]} ))
}

export stop=
toggle_timer() {
  [ "$stop" = true ] && export stop= || export stop=true
}

# Wait user input
read -p '? ' input

# Modify input to fit the format that `date` can read
# s -> sec
# m -> min
# h -> hour
[[ "$input" =~ s && ! "$input" =~ sec  ]] && input="$(sed s/s/sec/  <<<"$input")"
[[ "$input" =~ m && ! "$input" =~ min  ]] && input="$(sed s/m/min/  <<<"$input")"
[[ "$input" =~ h && ! "$input" =~ hour ]] && input="$(sed s/h/hour/ <<<"$input")"

start=$(date +%s)               # unix epoch of start
given=$(date +%s -d "$input")   # unix epoch of end
period=$(( $given - $start ))   # seconds for timer

time=0
while [ $time -ne $period ]; do
    [ "$stop" = true ] && sleep 0.3 && continue

    time="$(( $(date +%s) - $start ))"
    case ${display_list[$DISPLAY]} in
      STOPWATCH)
        printf '%s\r' "$(date -u -d @$time +%H:%M:%S)"
        ;;
      COUNTDOWN)
        printf '%s\r' "$(date -u -d @$((period - $time)) +%H:%M:%S)"
        ;;
      PERIOD)
        printf '%s\r' "$(date -u -d @$period +%H:%M:%S)"
        ;;
    esac

    sleep 0.3
done

printf "\e[1;31m$(date -u -d "@$time" +%H:%M:%S)"
