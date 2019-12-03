#! /bin/bash

set -x

ACCESS_TOKEN=$(cat ~/settings/tokens/mapbox)
export MAPBOX_ACCESS_TOKEN=$ACCESS_TOKEN
LIMIT=10

paste -d' ' \
    <(sed -nr '/<trk>/,/<\/trk>/ { s/.*<time>(.*)<\/time>/\1/p }' $1) \
    <(sed -nr 's/.*lon=\"([^\"]+)\" lat=\"([^\"]+)\".*/[\1,\2]/p' $1) \
    > origin

while true
do
    jq --slurp '{type: "Feature", properties: {coordTimes: .[1]}, geometry: {type: "LineString", coordinates: .[0]}}' \
        <(head -$LIMIT origin | cut -d' ' -f2 | jq -n '[inputs]') \
        <(head -$LIMIT origin | cut -d' ' -f1 | jq -nR '[inputs]') |\
    mapbox mapmatching --profile mapbox.driving  - > response

    jq -c '.features[0].geometry.coordinates[]' response |\
    while read line
    do
        paste -d' ' \
            <(jq -c '.features[0].properties.matchedPoints[]' response) \
            <(jq -c '.features[0].properties.indices[]' response | xargs -I{} echo {}+1 | bc | tee /dev/tty | xargs -I{} sed -n {}p origin | cut -d' ' -f1) |\
        grep -F $line || echo $line
    done

    sed -i "1,$LIMIT d" origin
    if [ ! -s origin ]; then exit 0; fi
done

#sed -nr 's/.*lon=\"([^\"]+)\" lat=\"([^\"]+)\".*/\1,\2/p' $1 |\
#xargs -L100 echo -n |\
#echo jojo
#tr ' ' ';' |\
#sed 's/^/coordinates=/' |\
#curl -X POST \
#    --data @- \
#    https://api.mapbox.com/matching/v4/mapbox/driving?access_token=$ACCESS_TOKEN&geometries=geojson&steps=true

