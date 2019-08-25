#!/bin/bash

for name in $(cat qlist)
do
    wd label $name | xargs -I{} grep {} name-list
    echo $name
done
