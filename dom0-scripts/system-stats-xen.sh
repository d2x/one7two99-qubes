#!/bin/sh
# Author: tasket
# presented in Qubes OS User Groups
# https://github.com/tasket/Qubes-scripts/blob/master/system-stats-xen

delay=5
#sensor_lines='Package id 0|fan1'

lnparse () {
  if [ "$2" = 'CPU(%)' ]; then
    clear
 #   sensors |grep -E "^($sensor_lines)"
    echo -e "\nVM NAME               CPU(% )    MEMORY(MB)"
  else
    echo "$ln"
  fi
}

clear
stdbuf -oL xentop -b -f -d $delay \
| stdbuf -oL awk '{sub(/\.[0-9]/, "  ")} {printf ("%-20s   %5s     %7\047d\n", $1,$4,$5/1000) }' \
| while read ln; do
    lnparse $ln
  done



