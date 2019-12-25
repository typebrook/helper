#!/bin/bash

# $1 as file, $2 as topic (Daily, Weekly, Monthly)
# change markdown check-list to empty
sed -i "/^## $2/,/^$/ s/\[.\]/\[ \]/" $1
