#!/bin/bash

for name in $(cat qlist)
do
    echo $name
    wd set-description $name en "A cyclone given name adopted by by ESCAP/WMO Typhoon Committee"
done
