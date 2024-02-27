#!/usr/bin/env bash

DBinAction=$1

function tableCreator() {
    isPrimaryKey=false
    metaData=$DATA_HEADER
    tableHeader=""

    readValidName "$PROMPT_READ_TABLE_NAME"
    tableName=$(retrieveValidatedInput)

    readValidNumeric "$PROMPT_READ_COL_NUMBER"
    numOfColumns=$(retrieveValidatedInput)

    for counter in $(seq "$numOfColumns"); do

        readValidName "$PROMPT_READ_COL_NAME$counter: "
        columnName=$(retrieveValidatedInput)

        columnType=$(readColumnType "$columnName")

        tableHeader+=$columnName
        metaData+=$columnName$DATA_SEPARATOR$columnType$DATA_SEPARATOR

        if [[ $isPrimaryKey == false ]]; then
            if confirmPKAssignment; then
                metaData+=true
                isPrimaryKey=true
            else
                metaData+=false
            fi
        else
            metaData+=false
        fi

        if [ "$counter" -lt "$numOfColumns" ]; then
            metaData+=$DATA_NEW_LINE
            tableHeader+=$DATA_SEPARATOR
        fi
    done

    writeToFiles "$metaData" "$tableHeader"

    tableMenu
}

function readColumnType() {
    local readColHeader
    readColHeader=$(echo -e "$PROMPT_READ_COL_TYPE $1")
    unset "$readColHeader"

    local type
    select ch in "$DATA_INTEGER" "$DATA_STRING"; do
        case $ch in
        "$DATA_INTEGER" | "$DATA_STRING")
            type="$ch"
            break
            ;;
        *)
            local error
            error=$(printError "$PROMPT_INVALID_INPUT")
            unset "$error"
            ;;
        esac
    done
    echo "$type"
}

function confirmPKAssignment() {
    if confirmChoice "$PROMPT_ASSIGN_AS_PK"; then
        return 0
    fi
    return 1
}

function writeToFiles() {
    local meta=$1
    local header=$2

    tablePath="$DBinAction/$tableName"
    metaTablePath="$DBinAction/.${tableName}.meta"

    if echo -e "$meta" >"$metaTablePath" && echo -e "$header" >"$tablePath"; then
        printSuccess "$PROMPT_TABLE_CREATION_DONE"
    else
        printError "$PROMPT_TABLE_CREATION_ERROR"

    fi
}

tableCreator
