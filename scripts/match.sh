#! /bin/bash

#set -x

ACCESS_TOKEN=$(cat ~/settings/tokens/mapbox)

#paste -d' ' \
#    <(sed -nr '/<trk>/,/<\/trk>/ { s/.*<time>(.*)<\/time>/\1/p }' $1 | xargs -I {} date -d "{}" +%s --utc) \
#    <(sed -nr 's/.*lon=\"([^\"]+)\" lat=\"([^\"]+)\".*/\1 \2/p' $1)

sed -nr 's/.*lon=\"([^\"]+)\" lat=\"([^\"]+)\".*/\1,\2/p' $1 |\
xargs -L100 echo -n |\
echo jojo
#tr ' ' ';' |\
#sed 's/^/coordinates=/' |\
#curl -X POST \
#    --data @- \
#    https://api.mapbox.com/matching/v4/mapbox/driving?access_token=$ACCESS_TOKEN&geometries=geojson&steps=true

