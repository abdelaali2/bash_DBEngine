#!/usr/bin/env bash
function readInput() {
    read -rep "$1" input
    echo "${input// /_}"
}

function textValidator() {
    local input=$1
    if [[ $input =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        return 0
    else
        return 1
    fi
}

function numberValidator() {
    local input=$1
    if [[ $input == +([1-9]) ]]; then
        return 0
    else
        return 1
    fi
}

function confirmChoice() {
    echo -e "${STYLE_YELLOW}$1${STYLE_NC}"
    while true; do
        read -ren 1 answer
        case "$answer" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *)
            echo -e "${STYLE_ON_IRED}$PROMPT_INVALID_INPUT${STYLE_NC}"
            echo "Enter '$PROMPT_YES_OPTION' or '$PROMPT_NO_OPTION'."
            ;;
        esac
    done
}
