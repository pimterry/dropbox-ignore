#!/bin/bash
set -e

attr -q -s com.dropbox.ignored -V 1 $1
echo "Ignored $1"