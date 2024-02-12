#!/usr/bin/env bash
function readInput() {
    read -re -p "$1" input
    echo "${input// /_}"
}

function textValidator() {
    local input=$1
    if [[ $input == +([a-zA-Z]*) ]]; then
        echo true
    else
        echo false
    fi
}

function numberValidator() {
    local input=$1
    if [[ $input == +([1-9]) ]]; then
        echo true
    else
        echo false
    fi
}
