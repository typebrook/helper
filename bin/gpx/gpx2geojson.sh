#! /bin/bash

<$1 xq '.gpx |
  (
    label $out |
    if .wpt != null then [.wpt] else break $out end |
    flatten[] |
    {
      type: "Feature",
      properties: { name: .name },
      geometry: {
        type: "Point",
        coordinates: [
          (.["@lon"]|tonumber),
          (.["@lat"]|tonumber),
          (.ele | if . == null then null else tonumber end)
        ]
      }
    }
  ),
  (
    label $out |
    if .trk != null then [.trk] else break $out end |
    flatten[] |
    {
      type: "Feature",
      properties: { name: .name },
      geometry: {
        type: "MultiLineString",
        coordinates:
          [.trkseg] | flatten | map(
            .trkpt | map(
              [
                (.["@lon"]|tonumber),
                (.["@lat"]|tonumber),
                (.ele | if . == null then null else tonumber end)
              ]
            )
          )
      }
    }
  )
' | jq -s '
  {
    type: "FeatureCollection",
    features: .
  }
'
