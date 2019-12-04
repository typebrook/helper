#! /bin/bash

#set -x
set -e

ACCESS_TOKEN=$(cat ~/settings/tokens/mapbox)
LIMIT=10
ORIGIN_DATA=/tmp/origin
RESPONSE=/tmp/response

# store data of time and location into tmp file with 2 columns, format is like:
# 1970-01-01T08:00:46 [121.0179739,14.5515336]
paste -d' ' \
    <(sed -nr '/<trk>/,/<\/trk>/ { s/.*<time>(.*)<\/time>/\1/p }' $1 | cut -d'.' -f1) \
    <(sed -nr 's/.*lon=\"([^\"]+)\".*/\1/p' $1) \
    <(sed -nr 's/.*lat=\"([^\"]+)\".*/\1/p' $1) |\
sed -r 's/ ([^ ]+) ([^ ]+)/ [\1,\2]/' |\
awk '!_[$1]++' > $ORIGIN_DATA
exit 0

while [ -s $ORIGIN_DATA ]
do
    jq --slurp '{type: "Feature", properties: {coordTimes: .[1]}, geometry: {type: "LineString", coordinates: .[0]}}' \
        <(head -$LIMIT $ORIGIN_DATA | cut -d' ' -f2 | jq -n '[inputs]') \
        <(head -$LIMIT $ORIGIN_DATA | cut -d' ' -f1 | jq -nR '[inputs]') |\
    curl -X POST -s --header "Content-Type:application/json" --data @- https://api.mapbox.com/matching/v4/mapbox.driving.json?access_token=$ACCESS_TOKEN > $RESPONSE

    TIMESTAMP=0
    paste -d' ' \
        <(jq -c '.features[0].properties.matchedPoints[]' $RESPONSE) \
        <(jq -c '.features[0].properties.indices[]' $RESPONSE | xargs -I{} echo {}+1 | bc | xargs -I{} sed -n {}p $ORIGIN_DATA | cut -d' ' -f1 | date -f - +%s) \
    > matched
    jq -c '.features[0].geometry.coordinates[]' $RESPONSE |\
    while read line
    do
        TIMESTAMP=$(head -1 matched | cut -d' ' -f2)
        (head -1 matched | grep -F $line && sed -i 1d matched) || echo $line $TIMESTAMP jojo
    done |\
    tee /dev/tty && rm matched

    sed -i "1,$LIMIT d" $ORIGIN_DATA
done |\
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
    " | tee output.gpx
