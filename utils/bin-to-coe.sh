#!/usr/bin/env sh

du -b --total "$@" >&2

printf "memory_initialization_radix=16;\n"
printf "memory_initialization_vector="
cat "$@" | xxd -c1 -p - | tr '\n' ',' | sed 's/,$//'
printf ";\n"

