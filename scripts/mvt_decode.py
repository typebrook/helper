import mapbox_vector_tile
import sys

#Python3

mvt = sys.argv[1]

with open(mvt, 'rb') as f:
    data = f.read()
    decoded_data = mapbox_vector_tile.decode(data)
    with open(mvt + '_decode.txt', 'w') as f:
        print(decoded_data)
