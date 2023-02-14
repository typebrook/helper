#! /bin/env python3

import mapbox_vector_tile
import sys

mvt = sys.argv[1]

with open(mvt, 'rb') as f:
    data = f.read()
    decoded_data = mapbox_vector_tile.decode(data)
    print(decoded_data)
