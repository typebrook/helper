#!/bin/bash

sed '/<trk>/,/<\/name>/ d; /<\/trk>/ d; /<\/gpx>/ i \ \ <\/trk>' |\
awk '/<trkseg>/ && !x {print "  <trk>\n    <name>combined_trk</name>"; x=1} 1'
