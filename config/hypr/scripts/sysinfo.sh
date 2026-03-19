#!/usr/bin/env bash
# CPU: two-sample read from /proc/stat for accurate %, no external tools
read -r _ u1 n1 s1 i1 q1 si1 st1 _ < /proc/stat
sleep 0.3
read -r _ u2 n2 s2 i2 q2 si2 st2 _ < /proc/stat

idle_diff=$(( i2 - i1 ))
total_diff=$(( (u2+n2+s2+i2+q2+si2+st2) - (u1+n1+s1+i1+q1+si1+st1) ))
cpu=$(( 100 - 100 * idle_diff / total_diff ))

ram=$(free -m | awk '/^Mem:/{print $3}')

echo "󰻠 ${cpu}%   󰍛 ${ram}MB"
