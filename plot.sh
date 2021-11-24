#!/bin/bash

gnuplot --persist <<INP
unset key
set xdata time
set timefmt "%m/%d/%y"
set xrange ["11/24/21":"12/01/21"]
set timefmt "%Y-%m-%dT%H:%M:%S"
plot "$1" using 1:2 with lines
INP
