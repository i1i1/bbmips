#!/bin/sh

make || exit 1

./bin/bbas $1
./bin/tohex v.out > proc/v.out
cd proc
iverilog proc.v && ./a.out

