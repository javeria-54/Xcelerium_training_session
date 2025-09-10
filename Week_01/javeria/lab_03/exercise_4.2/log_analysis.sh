#!/bin/bash

logfile="log.txt"
echo "Log Analysis"
total_entries=$(wc -l < "$logfile")
echo "Total entries: $total_entries"
echo
echo "Unique usernames:"
awk 'NF {print $2}' "$logfile" | sort | uniq
echo
echo "Actions per user:"
awk 'NF {print $2}' "$logfile" | sort | uniq -c |
while read count user;
do
    echo "$user: $count"
done

