#!/bin/bash
set -e

attr -s com.dropbox.ignored -V 1 $1 > /dev/null
echo "Ignored $1"