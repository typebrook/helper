#! /bin/bash

# Restore mail in variable
MAIL="$(cat)"

# Only execute the following script when mail receiver is log@topo.tw
grep -qE "^X-Original-To: .*log@topo.tw[>]?$" <<<"$MAIL" || exit 0
# A little hacky way to check if mail is sent from me
sed -nE '/^Received: /p;/^$/q' <<<"$(MAIL)" | wc -l | xargs -i test {} -lt 2 || exit 0

# Write a log
date >>~/Downloads/log.log
echo $$ >>~/Downloads/log.log
awk -v RS= 'NR>1' <<<"$MAIL"  >>~/Downloads/log.log

LOG=~/log/`date +%y.w%W.md`
TODAY="`date '+%a %b.%d'`"

# If header of today doesn't exist
# Create it and separate with 2 empty lines
grep -Eq "^## ${TODAY}$" ${LOG} || \
cat <<EOF >>${LOG}


## $TODAY
EOF


# Save content to log file of current week
echo >>${LOG}
awk -v RS= 'NR>1' <<<"$MAIL" >>${LOG}

# git commit
{ cd ~/log && git add `basename ${LOG}` && git commit -m "Update by mail"; } >>~/Downloads/log.log
