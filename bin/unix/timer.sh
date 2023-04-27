#! /bin/bash
# Ref: https://superuser.com/questions/611538/611582#611582

exec 3>&1
exec 1>/dev/tty

SIGNAL=${1:-SIGTERM}
COMMAND_START="$2"
COMMAND_EXIT="$3"

[ -n "$COLOR" ] && echo -en "\e[${COLOR}m"

# If SIGNAL is received, switch to next display
trap 'next_display' "$SIGNAL"
# Use SIGTSTP (Ctrl-Z in most of the cases) to stop/restart timer
trap 'toggle_timer' SIGTSTP

# Do not print "^C" when SIGINT caught
stty -ctlecho

# Hide the cursor
tput civis

display_list=(STOPWATCH COUNTDOWN PERIOD)
display=0

next_display() {
  display=$(( ("$display" + 1) %${#display_list[@]} ))
}

export stop=0
toggle_timer() {
  export stop=$(( ("$stop" + 1) %2 ))
}

# Wait user input
read -p '? ' -r input
# Disable input on terminal
stty -echo 
# If COMMAND_START is given, run it after timer is set
result="$([ -n "$COMMAND_START" ] && eval "$COMMAND_START" 2>&1)"
notify-send "$result" &>/tmp/openbox


# Modify input to fit the format that `date` can read
hour=$(grep -o '[0-9.]\+h' <<<"$input" | tr -d h)
min=$(grep -o '[0-9.]\+m'  <<<"$input" | tr -d m)
sec=$(grep -o '[0-9.]\+s'  <<<"$input" | tr -d s)

# seconds user set
SET=$( echo "${hour:-0}*3600 + ${min:-0}*60 + ${sec:-0}" | bc )
# Make sure the value is integer, prevent fail in shell comparison
SET=${SET%%.*}

# seconds pass
count=0

timer() {
  start=$(date +%s)
  count_from=$count

  while [ $count -lt $SET ]; do

    # If signal for stop is receive, stop counting
    [ $stop = 1 ] && sleep 0.3 && break

    count=$(( count_from + $(date +%s) - start ))
    case ${display_list[$display]} in
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

trap 'exec 1>&3; [ -n "COMMAND_EXIT" ] && eval "$COMMAND_EXIT" && unset COMMAND_EXIT; echo `date` $1 >>/tmp/timer.sh; ' EXIT HUP

while [ $count -lt $SET ]; do
  [ $stop = true ] && sleep 0.3 && continue
  timer
done

# Print bold red text of time that user set
printf "\e[1;31m%s" "$(date -u -d "@$SET" +%H:%M:%S)"
