#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Error: provide a number as an argument"
    exit 1
fi

factorial() {
    num=$1
    fact=1
    for (( i=1; i<=num; i++ ))
    do
        fact=$((fact * i))
    done
    echo "Factorial of $num is: $fact"
}

factorial $1

