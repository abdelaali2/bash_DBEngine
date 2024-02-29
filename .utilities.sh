#!/usr/bin/env bash

function sourceFile() {
    # shellcheck disable=SC1090
    source "$1" "${@:2}"
}

# TODO: embed the error message handler globally
function handleErrorMessage() {
    local error_message
    clear

    while [ $# -gt 0 ]; do
        case "$1" in
        --error)
            shift
            error_message="$1"
            ;;
        esac
        shift
    done

    printError "$error_message"
}

function readSanitizedText() {
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

function positiveNumberValidator() {
    regexChecker "$1" "$REGEX_POSITIVE_NUMBERS"
    return $?
}

function integerValidator() {
    regexChecker "$1" "$REGEX_ANY_NUMBER"
    return $?
}

function regexChecker() {
    if [[ $1 =~ $2 ]]; then
        return 0
    else
        return 1
    fi
}

# TODO: add support for receiving commands and execting them at validation
# TODO: Implement unified validation function

function readValidName() {
    local name
    name=$(readSanitizedText "$1")

    until nameValidator "$name"; do
        # clear
        printError "$PROMPT_INVALID_NAME"
        name=$(readSanitizedText "$1")
    done
    echo "$name" >"$VALIDATION_STATE"
}

# TODO: change this function name to readValidPositiveNumber
function readValidNumeric() {
    local input
    if [ "$2" ]; then
        input=$2
    else
        input=$(readPlainText "$1")
    fi

    until positiveNumberValidator "$input"; do
        clear
        printError "$PROMPT_INVALID_INPUT"

        input=$(readPlainText "$1")
    done
    echo "$input" >"$VALIDATION_STATE"
}

function readValidInteger() {
    local input
    if [ "$2" ]; then
        input=$2
    else
        input=$(readPlainText "$1")
    fi

    until integerValidator "$input"; do
        clear
        printError "$PROMPT_INVALID_INPUT"

        input=$(readPlainText "$1")
    done
    echo "$input" >"$VALIDATION_STATE"
}

function retrieveValidatedInput() {
    local value
    value=$(cat "$VALIDATION_STATE")
    echo "" >"$VALIDATION_STATE"
    echo "$value"
}

function confirmChoice() {
    printWarning "$1"
    while true; do
        # TODO: change to silent reading
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
    echo -e "==>${STYLE_BLUE} $1${STYLE_NC}\n"
}

# TODO: rename this function to printColumn
function printList() {
    while IFS= read -r line; do
        echo -e " $line"
    done <<<"$1"
}

function printGreeting() {
    echo -e "${STYLE_ON_IMAGENTA}$1${STYLE_NC}"
}

function checkTableExistance() {
    local dir
    dir=$(dirname "$1")
    local table
    table=$(basename "$1")
    local meta="$dir/.$table.meta"
    if [ ! -f "$1" ] || [ ! -f "$meta" ]; then
        printError "$PROMPT_TABLE_NOT_FOUND"
        return 1
    fi

    return 0
}

function pauseExecution() {
    readPlainText "$PROPMPT_ENTER_TO_CONTINUE"
    clear
}

function checkNotEmpty() {
    if [ -f "$1" ]; then
        checkNotEmptyFile "$@"
    else
        checkNotEmptyData "$@"
    fi
    return $?
}

function checkNotEmptyFile() {
    if [[ $(wc -l "$1" | cut -d' ' -f1) -le 1 ]]; then
        printWarning "$2"
        return 1
    fi

    return 0
}

function checkNotEmptyData() {
    if [ -z "$1" ]; then
        printWarning "$2"
        return 1
    fi

    return 0
}
