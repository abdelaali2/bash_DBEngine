#!/usr/bin/env bash

DBinAction=$1

function dropTable() {
    sourceFile "$SCRIPT_LIST_TABLES" "$DBinAction" "skipTableMenu"

    readValidName "$PROMPT_READ_TABLE_NAME"
    tableName=$(retrieveValidatedInput)

    tablePath="./$DBinAction/$tableName"
    metaTablePath="./$DBinAction/.$tableName.meta"

    if confirmChoice "$tableName:\n\t $PROPMPT_TABLE_DELETEION_CONFIRM"; then
        if rm -r "$tablePath" "$metaTablePath" 2>/dev/null; then
            printSuccess "$PROMPT_TABLE_DELETION_DONE"
        else
            printError "$PROMPT_TABLE_DELETION_ERROR"
        fi
    else
        printWarning "$PROMPT_TABLE_DELETION_CANCELLED"
    fi

    tableMenu
}

dropTable
