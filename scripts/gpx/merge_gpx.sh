#!/bin/bash

GPX_DIR=$(dirname $0)

sed '/<trk/,/<\/trk>/ p' -nr | cat $GPX_DIR/header - | cat - $GPX_DIR/footer
