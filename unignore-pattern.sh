#!/bin/bash
set -e

find $1 -path "*/$2" -print0 | xargs -0 -n1 -P8 ./unignore-file.sh