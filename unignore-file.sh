#!/bin/bash
set -e

attr -r com.dropbox.ignored $1 > /dev/null
echo "Unignored $1"