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

# put yout Mapbox token here
ACCESS_TOKEN=$(cat ~/settings/tokens/mapbox)
# number of coordinates for each Mapbox Map Matching API request, Maximum value is 100
LIMIT=10

ORIGIN_DATA=/tmp/origin
RESPONSE=/tmp/response

# extract data from the given gpx file, dump coordindate and time with the following format:
# [121.0179739,14.5515336] 1984-01-01T08:00:46.234
function get_data() {
    # FIXME sometimes trkpt doesn't contains time, need to return empty line
    paste -d' ' \
        <(sed -nE '/<trkpt /,/<\/trkpt>/ s/.*lon="([^"]+).*/\1/p' $1) \
        <(sed -nE '/<trkpt /,/<\/trkpt>/ s/.*lat="([^"]+).*/\1/p' $1) \
        <(sed -nE '/<trkpt /,/<\/trkpt>/ {}' $1) |\
    sed -nE 's/^([^ ]+) ([^ ]+)/[\1,\2\]/p' |\
    awk '!_[$2]++'
}

get_data $1 # > $ORIGIN_DATA
exit 0

# Consume raw data with serveral request
while [ -s $ORIGIN_DATA ]; do
    # Make GeoJSON object for request
    jq --slurp '{type: "Feature", properties: {coordTimes: .[1]}, geometry: {type: "LineString", coordinates: .[0]}}' \
        <(head -$LIMIT $ORIGIN_DATA | cut -d' ' -f2 | jq -n '[inputs]') \
        <(head -$LIMIT $ORIGIN_DATA | cut -d' ' -f1 | jq -nR '[inputs]') |\
    tee tmp_$(head -1 $ORIGIN_DATA | cut -d ' ' -f1 | date -f - +%s).geojson |\
    # Mapbox Map Matching API, store response into tmp file
    curl -X POST -s  --data @- --header "Content-Type:application/json" https://api.mapbox.com/matching/v4/mapbox.driving.json?access_token=$ACCESS_TOKEN > $RESPONSE

    # Put existing timestamps to matched points, and interpolate new timestamps into new points
    join -a1 \
        <(jq -c  '.features[0].geometry.coordinates[]' $RESPONSE) \
        <(jq -cr '.features[0].properties | [.matchedPoints, (.indices | map(.+1))] | transpose[] | "\(.[0]) \(.[1])"' $RESPONSE) |\
    sed '/ / !s/$/ -1/' |\
    while read coor index; do
        if [ $index -gt -1 ]; then
            echo $coor $(sed -n "$index p" $ORIGIN_DATA | cut -d' ' -f1 | date -f - +%s)
        else
            echo $coor $index
        fi
    done |\
    awk '{COOR[NR][0]=$1; N++; COOR[NR][1]=$2} END{for (i=1; i<=N; i++) {printf COOR[i][0]; if (COOR[i][1] != -1) {print " "COOR[i][1]; LAST=i} else {while(COOR[i+n][1] == -1) n++; print " "COOR[LAST][1]+(COOR[i+n][1]-COOR[LAST][1])*(i-LAST)/(i+n-LAST)}}}' |\
    while read coor unix_time; do
        # Transform unix timestamp into human readable time format, like following:
        # Transform [121.018088,14.5516] 18.50
        # Into      [121.018088,14.5516] 1970-01-01T08:00:18.50Z
        echo $coor $(date -d @$unix_time +'%Y-%m-%dT%H:%M:%S.%2NZ')
    done | tee /dev/tty

    # Remove processed raw data
    sed -i "1,$LIMIT d" $ORIGIN_DATA
done |\
# Make GPX format for output
sed -E 's/\[([^,]+),([^,]+)\] (.*)/      <trkpt lon="\1" lat="\2"><time>\3<\/time><\/trkpt>/' |\
sed "1i \
<gpx version=\"1.1\" creator=\"Garmin Connect\"\n\
  xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd\"\n\
  xmlns=\"http://www.topografix.com/GPX/1/1\"\n\
  xmlns:gpxtpx=\"http://www.garmin.com/xmlschemas/TrackPointExtension/v1\"\n\
  xmlns:gpxx=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n\
  <trk>\n\
    <name>$(sed -nE 's/.*<name>(.*)<\/name>.*/\1/p; /<name>/q' $1)<\/name>\n\
    <trkseg>
\$a \
\ \ \ \ <\/trkseg>\n\
  <\/trk>\n\
<\/gpx>\n\
    "

