#! /bin/bash
# Ref: https://superuser.com/questions/611538/611582#611582

tput civis
read -p '? ' input

[[ "$input" =~ s && ! "$input" =~ sec  ]] && input="$(sed s/s/sec/  <<<"$input")"
[[ "$input" =~ m && ! "$input" =~ min  ]] && input="$(sed s/m/min/  <<<"$input")"
[[ "$input" =~ h && ! "$input" =~ hour ]] && input="$(sed s/h/hour/ <<<"$input")"

time=0
start=$(date +%s)
given=$(date +%s -d "$input")
stop=$(( $given - $start ))
while [ $time -ne $stop ]; do
    time="$(( $(date +%s) - $start ))"
    printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
    sleep 0.3
done
printf "\e[1;31m$(date -u -d "@$time" +%H:%M:%S)"
