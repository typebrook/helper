#!/bin/bash

GPX_DIR=$(dirname $0)

sed '/<trk/,/<\/trk>/ p' -nr | cat $GPX_DIR/head - | cat - $GPX_DIR/tail
