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

function confirmChoice() {
    echo -e "${STYLE_YELLOW}$1${STYLE_NC}"
    select ch in "$PROMPT_YES_OPTION" "$PROMPT_NO_OPTION"; do
        case $ch in
        "$PROMPT_YES_OPTION")
            return 0
            ;;
        "$PROMPT_NO_OPTION")
            return 1
            ;;
        [Yy]*)
            return 0
            ;;
        [Nn]*)
            return 1
            ;;
        *)
            return 2
            ;;
        esac
    done
}
