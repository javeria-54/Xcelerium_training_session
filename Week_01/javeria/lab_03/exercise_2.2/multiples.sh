#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Error: provide a number as an argument"
    exit 1
fi

n=$1

for ((i=1; i<11; i++))
do
	echo " multiple are $((i*n))"
 done

 