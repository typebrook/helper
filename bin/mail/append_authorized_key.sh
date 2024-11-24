#! /bin/bash

# Append last line of mail into ~/.ssh/authorized_keys
# Usage:
#   1. put this file into ~/.forward
#   2. send mail with header "Passphase: ", and value in ~/.config/passphase
#   3. try ssh

# Restore mail in variable
MAIL="$(cat)"

# Get user passphase
test -f ~/.config/passphase || exit 1
PASSPHASE="$(cat ~/.config/passphase)"

# Only execute the following script when header matched
grep -qE "^Passphase: ${PASSPHASE}" <<<"$MAIL" || exit 0

# Append comment and last line to ~/.ssh/authorized_keys
exec 1>>~/.ssh/authorized_keys
<<<"$MAIL" grep 'From:' | head -1 | sed 's/^/# /'
<<<"$MAIL" sed -En '/^.+/p' | tail -1
