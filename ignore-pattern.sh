#!/bin/bash
set -e

find $1 -path "*/$2" -prune -print0 | xargs -0 -n1 -P8 ./ignore-file.sh