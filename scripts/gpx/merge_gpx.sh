#!/bin/bash

GPX_DIR=$(dirname $0)

sed '/<trk/,/<\/trk>/ p' -nr | cat $GPX_DIR/header - $GPX_DIR/footer
