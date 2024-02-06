#!/usr/bin/env bash
function readInput() {
    read -re -p "$1" input
    echo "${input// /_}"
}

function validator() {
    local input=$1
    if [[ $input == +([a-zA-Z]*) ]]; then
        echo true
    else
        echo false
    fi
}
