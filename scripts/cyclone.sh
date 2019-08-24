#!/usr/bin/env bash

NAME=$1
wd ci "{\"labels\": {\"en\": \"$NAME\"}, \"claims\": {\"P31\": \"Q66724080\", \"P361\": \"Q66724586\"}}"
