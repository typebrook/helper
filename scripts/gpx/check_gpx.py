#!/usr/bin/env python3

import sys
import os
import argparse
import copy
import fileinput
from osgeo import ogr
import osr
import urllib.parse

def rewrite_gpx(filename):
    for line in fileinput.input(filename, inplace=True):
        if fileinput.isfirstline() and "'" in line:
            line = '<?xml version="1.0" encoding="UTF-8"?>'
        if fileinput.filelineno() == 2 and "version" not in line:
            line = line.replace('<gpx', '<gpx version="1.1"')
        print(line.rstrip('\n'))

def check_valid(filename, threshold, add_prefix):
    rewrite_gpx(filename)

    driver = ogr.GetDriverByName('GPX')
    try:
        dataSource = driver.Open(filename)
    except Exception:
        pass
    if dataSource is None:
        print("could not open")
        sys.exit(1)

    inSpatialRef = osr.SpatialReference()
    inSpatialRef.ImportFromEPSG(4326)
    outSpatialRef = osr.SpatialReference()
    outSpatialRef.ImportFromEPSG(3857)
    to3857 = osr.CoordinateTransformation(inSpatialRef, outSpatialRef)
    to4326 = osr.CoordinateTransformation(outSpatialRef, inSpatialRef)

    trkLayer = dataSource.GetLayer(4)
    trkpt = trkLayer.GetNextFeature()
    flag = False
    while trkpt:
        nextTrkpt = trkLayer.GetNextFeature()
        if nextTrkpt:
            geom1 = trkpt.GetGeometryRef()
            geom1.Transform(to3857)
            geom2 = nextTrkpt.GetGeometryRef()
            geom2.Transform(to3857)
            distance = geom1.Distance(geom2)

            geom1.Transform(to4326)
            geom2.Transform(to4326)
            if distance >= threshold:
                if not flag:
                    print(f'{filename} has problem, the following urls shows the points with distance far from {threshold}m:')
                    print()
                    flag = True
                    if add_prefix:
                        dir = os.path.dirname(filename)
                        if dir:
                            dir += '/'
                        os.rename(filename, f'{dir}invalid_{os.path.basename(filename)}')

                geojson = '{{"type": "LineString", "coordinates": [[{}, {}], [{}, {}]]}}'.format(
                    geom1.GetX(), geom1.GetY(),
                    geom2.GetX(), geom2.GetY()
                )
                encoded = urllib.parse.quote(geojson)
                print('http://geojson.io/#data=data:application/json,{}'.format(encoded))
                print()
        else:
            break
        trkpt = nextTrkpt

def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help="you can add multiple gpx files at the same time", nargs='+')
    parser.add_argument("-i", help="add prefix to invalid files", action="store_true")
    parser.add_argument("-d", help="distance of tolerance(m), 100 by default", dest="distance", default=100)
    args = parser.parse_args()
    for file in args.file:
        check_valid(file, args.distance, args.i)

if __name__ == '__main__':
    main(sys.argv)
