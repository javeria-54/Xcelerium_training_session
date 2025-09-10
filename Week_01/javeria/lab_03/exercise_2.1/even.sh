#!/bin/bash

if [ $# -eq 0 ]
then
    echo "provide a number as an argument"
    exit 1
fi

number=$1

if [ $((number % 2)) -eq 0 ]
then
    echo "$number is even"
else
    echo "$number is odd"
fi
