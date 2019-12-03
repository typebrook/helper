#! /bin/bash

#set -x

ACCESS_TOKEN=$(cat ~/settings/tokens/mapbox)
#export MAPBOX_ACCESS_TOKEN=$ACCESS_TOKEN
LIMIT=100
TRK_NAME=$(sed -nr 's/.*<name>(.*)<\/name>.*/\1/p; /<name>/q' $1)

# Need to add pre-process for duplicated gpx trkpts
paste -d' ' \
    <(sed -nr '/<trk>/,/<\/trk>/ { s/.*<time>(.*)<\/time>/\1/p }' $1 | cut -d'.' -f1) \
    <(sed -nr 's/.*lon=\"([^\"]+)\".*/\1/p' $1) \
    <(sed -nr 's/.*lat=\"([^\"]+)\".*/\1/p' $1) |\
sed -r 's/ ([^ ]+) ([^ ]+)/ [\1,\2]/' |\
awk '!_[$1]++' |\
awk '!_[$2]++' > origin

while [ -s origin ]
do
    jq --slurp '{type: "Feature", properties: {coordTimes: .[1]}, geometry: {type: "LineString", coordinates: .[0]}}' \
        <(head -$LIMIT origin | cut -d' ' -f2 | jq -n '[inputs]') \
        <(head -$LIMIT origin | cut -d' ' -f1 | jq -nR '[inputs]') |\
    tee input.geojson |\
    curl -X POST -s --header "Content-Type:application/json" --data @- https://api.mapbox.com/matching/v4/mapbox.driving.json?access_token=$ACCESS_TOKEN > response

    jq -c '.features[0].geometry.coordinates[]' response |\
    while read line
    do
        paste -d' ' \
            <(jq -c '.features[0].properties.matchedPoints[]' response) \
            <(jq -c '.features[0].properties.indices[]' response | xargs -I{} echo {}+1 | bc | xargs -I{} sed -n {}p origin | cut -d' ' -f1 | date -f - +%s) |\
        grep -F $line | head -1 || echo $line
    done |\
    tee /dev/tty

    sed -i "1,$LIMIT d" origin
done |\
sed -r 's/\[([^,]+),([^,]+)\] (.*)/      <trkpt lon="\1" lat="\2"><time>\3<\/time><\/trkpt>/' |\
sed "1i \
<gpx version=\"1.1\" creator=\"Garmin Connect\"\n\
  xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd\"\n\
  xmlns=\"http://www.topografix.com/GPX/1/1\"\n\
  xmlns:gpxtpx=\"http://www.garmin.com/xmlschemas/TrackPointExtension/v1\"\n\
  xmlns:gpxx=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n\
  <trk>\n\
    <name>$TRK_NAME<\/name>\n\
    <trkseg>
\$a \
\ \ \ \ <\/trkseg>\n\
  <\/trk>\n\
<\/gpx>\n\
    " |\
tee output.gpx
