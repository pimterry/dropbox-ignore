#!/bin/bash
set -e

attr -q -r com.dropbox.ignored $1
echo "Unignored $1"