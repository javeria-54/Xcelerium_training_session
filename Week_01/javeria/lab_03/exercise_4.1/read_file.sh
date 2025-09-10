#!/bin/bash

filename="file.txt"
lineno=1
while read -r line
do 
		echo "$lineno: $line"
		((lineno++))

done < "$filename"

