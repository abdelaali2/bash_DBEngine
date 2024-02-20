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
    printWarning "$1"
    while true; do
        read -ren 1 answer
        case "$answer" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *)
            printError "$PROMPT_INVALID_INPUT"
            echo "Enter '$PROMPT_YES_OPTION' or '$PROMPT_NO_OPTION'."
            ;;
        esac
    done
}

function printError() {
    echo -e "${STYLE_ON_IRED}$1${STYLE_NC}"
}

function printSuccess() {
    echo -e "${STYLE_ON_IGREEN}$1${STYLE_NC}"
}

function printWarning() {
    echo -e "${STYLE_YELLOW}$1${STYLE_NC}"
}

function printListItem() {
    echo -e "==>  $1\n"
}

function readTableName() {
    tableName=$(readInput "$PROMPT_READ_TABLE_NAME")

    while ! textValidator "$tableName"; do
        clear
        printError "$PROMPT_INAVLID_TABLE_NAME"
        tableName=$(readInput "$PROMPT_READ_TABLE_NAME")
    done
    echo "$tableName"
}
