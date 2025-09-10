#!/bin/bash

number=$(( ( RANDOM % 10 ) + 1 ))

echo "guess a number between 1 to 10:"

while true
do
    read -p "enter your guess: " guess

    if [ "$guess" -eq "$number" ]; then
        echo " correct the number was $number"
        break
    elif [ "$guess" -lt "$number" ]; then
        echo "too low!"
    else
        echo "too high!"
    fi
done
