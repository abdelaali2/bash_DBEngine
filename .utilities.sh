#!/usr/bin/env bash
function readInput() {
    read -re -p "$1" input
    echo "${input// /_}"
}

function textValidator() {
    local input=$1
    if [[ $input == ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        reutrn 0
    else
        reutrn 1
    fi
}

function numberValidator() {
    local input=$1
    if [[ $input == +([1-9]) ]]; then
        reutrn 0
    else
        reutrn 1
    fi
}
