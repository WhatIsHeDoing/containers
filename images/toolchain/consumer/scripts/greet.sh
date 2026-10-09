#!/bin/sh
# Print a greeting, so shellcheck and shfmt have a script to check.
set -eu

name=${1:-world}
printf 'Hello, %s\n' "$name"
