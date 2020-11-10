#!/bin/bash
set -e

find $1 -exec ./is-ignored.sh {} \; -print