#!/bin/bash
set -e

attr -g com.dropbox.ignored $1 >/dev/null 2>&1
exit $?