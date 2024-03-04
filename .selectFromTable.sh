#!/usr/bin/env bash

DBinAction=$1

function selectFromTable() {
    handleErrorMessage

    sourceFile "$SCRIPT_LIST_TABLES" "$DBinAction" "skipTableMenu"

    checkAndPromptTableName() {
        readValidName "$PROMPT_READ_TABLE_NAME"
        tableName=$(retrieveValidatedInput)
        tablePath="$DBinAction/$tableName"
    }

    checkAndPromptTableName

    until checkTableExistance "$tablePath"; do
        sourceFile "$SCRIPT_LIST_TABLES" "$DBinAction" "skipTableMenu"
        checkAndPromptTableName
    done

    metaTablePath="$DBinAction/.$tableName.meta"

    select input in "$SELECT_ALL" "$SELECT_ENTIRE_COLUMN" "$SELECT_ENTIRE_ROW" "$SELECT_CERTAIN_VALUES" "$RETURN"; do
        case $input in

        "$SELECT_ALL")
            selectAll
            ;;

        "$SELECT_ENTIRE_COLUMN")
            selectEntireColumn
            ;;
        "$SELECT_ENTIRE_ROW" | "$SELECT_CERTAIN_VALUES")
            selectRow "$input"
            ;;
        "$RETURN")
            tableMenu
            ;;
        *)
            selectFromTable
            printError "$PROMPT_INVALID_INPUT"
            ;;
        esac
    done

    tableMenu
}

function selectAll() {
    local content
    content=$(awk -F"$DATA_SEPARATOR" '
        NR>1 {
            print
        }
    ' "$tablePath")

    displayResults "$tableName" "$content"

    pauseExecution
    tableMenu
}

function selectEntireColumn() {
    queryMetaTable "$metaTablePath"

    # shellcheck disable=SC2154
    selectedCol=$(getColIndex "$numOfCols")

    queryDataTable "$selectedCol" "$tablePath"

    pauseExecution
    tableMenu
}

function queryDataTable() {
    local result
    local header

    header=$(awk -F: -v grab="$1" 'NR==1 {
        print $grab
    }' "$2")

    result=$(awk -F: -v grab="$1" 'NR>1 {
        print $grab
    }' "$2")

    displayResults "$header" "$result"
}

function displayResults() {
    printSuccess "$1"
    if checkNotEmpty "$2" "$PROMPT_EMPTY_SET"; then
        printList "$2"
    fi
}

function selectRow() {
    local query
    query=$(readPlainText "$PROMPT_ENTER_QUERY")
    query=$(querySanitizer "$query")

    case "$1" in
    "$SELECT_ENTIRE_ROW")
        selectEntireRow "$query"
        ;;
    "$SELECT_CERTAIN_VALUES")
        selectCertainValues "$query"
        ;;
    esac

    displayResults "$PROMPT_QUERY_DONE" "$result"

    pauseExecution
    tableMenu
}

function querySanitizer() {
    if integerValidator "$1"; then
        echo "'$1'"
    else
        echo "$1"
    fi
}

function selectEntireRow() {
    result=$(grep -wis "$1" "$tablePath")
}

function selectCertainValues() {
    result=$(grep -wiso "$1" "$tablePath")
}

selectFromTable
