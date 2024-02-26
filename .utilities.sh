#!/usr/bin/env bash
function readInput() {
    plainText=$(readPlainText "$1")
    echo "${plainText// /_}"
}

function readPlainText() {
    read -rep "$(echo -e "$1")" input
    echo "$input"
}

function nameValidator() {
    regexChecker "$1" "$REGEX_NAMES"
    return $?
}

function numberValidator() {
    regexChecker "$1" "$REGEX_NUMERIC"
    return $?
}

function regexChecker() {
    if [[ $1 =~ $2 ]]; then
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

function printGreeting() {
    echo -e "${STYLE_ON_ICYAN}$1${STYLE_NC}"
}

function readTableName() {
    tableName=$(readInput "$PROMPT_READ_TABLE_NAME")

    while ! nameValidator "$tableName"; do
        clear
        printError "$PROMPT_INVALID_NAME"
        tableName=$(readInput "$PROMPT_READ_TABLE_NAME")
    done
    echo "$tableName"
}
