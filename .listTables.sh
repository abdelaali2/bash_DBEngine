#!/usr/bin/env bash

function listTables() {
    clear
    local DBinAction=$1
    local skipStatement=$2
    echo -e "$PROMPT_CURRENT_TABLES"
    for table in "$DBinAction"/*; do
        if [ -f "$table" ]; then
            printListItem "$(basename -a "$table")"
        fi
    done
    if [[ ! $skipStatement ]]; then
        tableMenu
    fi

    unset DBinAction
    unset skipStatement
}

listTables "$@"
