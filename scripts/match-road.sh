#!/usr/bin/env bash
#
# Author: Pham
#
# This script accepts a single GPX file as parameter and
# output the processed GPX body to STDOUT, using Mapbox Map Matching API v4.
# read doc at: https://docs.mapbox.com/api/legacy/map-matching-v4/
#
# Example:
#
# match-road.sh raw.gpx > new.gpx
#
# Hint:
#
# Remember to put Mapbox Access Token at the top!

#set -x
set -e

ACCESS_TOKEN=$(cat ~/settings/tokens/mapbox) # put yout Mapbox token here
LIMIT=10 # number of coordinates for each Mapbox Map Matching API request, Maximum value is 100

ORIGIN_DATA=/tmp/origin
RESPONSE=/tmp/response
MATCHED=/tmp/matched

# store data of time and location into tmp file with 2 columns, format is like:
# 1970-01-01T08:00:46 [121.0179739,14.5515336]
paste -d' ' \
    <(sed -nr '/<trk>/,/<\/trk>/ { s/.*<time>(.*)<\/time>/\1/p }' $1 | cut -d'.' -f1) \
    <(sed -nr 's/.*lon=\"([^\"]+)\".*/\1/p' $1) \
    <(sed -nr 's/.*lat=\"([^\"]+)\".*/\1/p' $1) |\
sed -r 's/ ([^ ]+) ([^ ]+)/ [\1,\2]/' |\
awk '!_[$1]++' > $ORIGIN_DATA

# Consume raw data with serveral request
while [ -s $ORIGIN_DATA ]
do
    # Make GeoJSON object for request
    jq --slurp '{type: "Feature", properties: {coordTimes: .[1]}, geometry: {type: "LineString", coordinates: .[0]}}' \
        <(head -$LIMIT $ORIGIN_DATA | cut -d' ' -f2 | jq -n '[inputs]') \
        <(head -$LIMIT $ORIGIN_DATA | cut -d' ' -f1 | jq -nR '[inputs]') |\
    # Mapbox Map Matching API
    curl -X POST -s  --data @- --header "Content-Type:application/json" https://api.mapbox.com/matching/v4/mapbox.driving.json?access_token=$ACCESS_TOKEN > $RESPONSE

    # Put matched points and indices into tmp file
    paste -d' ' \
        <(jq -c '.features[0].properties.matchedPoints[]' $RESPONSE) \
        <(jq -c '.features[0].properties.indices[]' $RESPONSE | xargs -I{} echo {}+1 | bc | xargs -I{} sed -n {}p $ORIGIN_DATA | cut -d' ' -f1 | date -f - +%s) \
    > $MATCHED

    # FIXME temporary solution for timestamp to unmatched points
    DURATION=$(jq '.features[0].properties.duration' $RESPONSE)
    INTERVAL=$(echo "scale=2;" $DURATION / $LIMIT | bc -l)

    # For each coodinates from Map Matching API, add timestamp at the end and print it out to tty
    jq -c '.features[0].geometry.coordinates[]' $RESPONSE |\
    while read line
    do
        if head -1 $MATCHED | grep -F $line; then
            TIMESTAMP=$(head -1 $MATCHED | cut -d' ' -f2)
            sed -i 1d $MATCHED
        else
            echo $line $(echo $TIMESTAMP + $INTERVAL | bc -l)
        fi
    done |\
    tee /dev/tty && rm $MATCHED

    # Remove processed raw data
    sed -i "1,$LIMIT d" $ORIGIN_DATA
done |\
# Make GPX format for output
sed -r 's/\[([^,]+),([^,]+)\] ?(.*)/      <trkpt lon="\1" lat="\2"><time>\3<\/time><\/trkpt>/' |\
sed "1i \
<gpx version=\"1.1\" creator=\"Garmin Connect\"\n\
  xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd\"\n\
  xmlns=\"http://www.topografix.com/GPX/1/1\"\n\
  xmlns:gpxtpx=\"http://www.garmin.com/xmlschemas/TrackPointExtension/v1\"\n\
  xmlns:gpxx=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n\
  <trk>\n\
    <name>$(sed -nr 's/.*<name>(.*)<\/name>.*/\1/p; /<name>/q' $1)<\/name>\n\
    <trkseg>
\$a \
\ \ \ \ <\/trkseg>\n\
  <\/trk>\n\
<\/gpx>\n\
    "
