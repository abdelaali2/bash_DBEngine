#!/usr/bin/env bash

DBinAction=$1

function readNumOfColumns() {
    numOfColumns=$(readInput "$PROMPT_READ_COL_NUMBER")

    while ! numberValidator "$numOfColumns"; do
        clear
        printError "$PROMPT_INVALID_INPUT"
        numOfColumns=$(readInput "$PROMPT_READ_COL_NUMBER")
    done
}

function tableCreator() {
    isPrimaryKey=false
    metaData=$DATA_HEADER
    tableHeader=""

    for counter in $(seq "$numOfColumns"); do
        columnName=$(readColumnName "$counter")
        tableHeader+=$columnName
        columnType=$(readColumnType "$columnName")

        if [[ $isPrimaryKey == false ]]; then
            if confirmPKAssignment; then
                metaData+=$columnName$DATA_SEPARATOR$columnType${DATA_SEPARATOR}true
                isPrimaryKey=true
            fi
        else
            metaData+=$columnName$DATA_SEPARATOR$columnType${DATA_SEPARATOR}false
        fi

        if [ "$counter" -lt "$numOfColumns" ]; then
            metaData+=$DATA_NEW_LINE
            tableHeader+=$DATA_SEPARATOR
        fi
    done

    writeToFiles "$metaData" "$tableHeader"

    tableMenu
}

function readColumnName() {
    local counter=$1
    columnName=$(readInput "$PROMPT_READ_COL_NAME$counter: ")

    while ! nameValidator "$columnName"; do
        local error
        error=$(printError "$PROMPT_INVALID_INPUT")
        unset "$error"
        columnName=$(readInput "$PROMPT_READ_COL_NAME$counter: ")
    done

    echo "$columnName"

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

tableName=$(readTableName)
readNumOfColumns
tableCreator
