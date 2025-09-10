#!/bin/bash

declare -A capitals
capitals=(
    ["Pakistan"]="Islamabad"  
    ["India"]="New Delhi"  
    ["China"]="Beijing"
    ["Japan"]="Tokyo"  
    ["USA"]="Washington D.C."  
    ["Turkey"]="Ankara"
    ["Iraq"]="Baghdad" 
    ["Iran"]="Tehran"  
    ["England"]="London"
    ["Portugal"]="Lisbon"   
    ["Spain"]="Madrid"  
    ["Germany"]="Berlin"
    ["France"]="Paris"  
    ["Malaysia"]="Kuala Lampur"  
    ["Egypt"]="Cairo"
    ["Syria"]="Damascus" 
    ["Jordan"]="Amman" 
    ["Libya"]="Tripoli"
    ["Bangladesh"]="Dhaka" 
    ["Palistine"]="Jerusalem" 
    ["Kawait"]="Kuwait City"
    ["Qatar"]="Doha" 
    ["Libanon"]="Beirut"
)

get_capital() {
    echo "enter a country name"
    read country

    if [[ -n "${capitals[$country]}" ]]; then
        echo "The capital of $country is: ${capitals[$country]}"
    else
        echo "Capital for '$country' was not found in the list."
    fi
}
get_capital

