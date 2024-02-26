#!/usr/bin/env bash

DBinAction=$1

function dropTable() {
    # shellcheck disable=SC1091
    # shellcheck disable=SC1090
    source "$SCRIPT_LIST_TABLES" "$DBinAction" "skipTableMenu"
    tableName=$(readTableName)

    if textValidator "$tableName"; then
        tablePath="./$DBinAction/$tableName"
        metaTablePath="./$DBinAction/.$tableName.meta"
        if confirmChoice "  $tableName:\n\t $PROPMPT_TABLE_DELETEION_CONFIRM"; then
            if rm -r "$tablePath" "$metaTablePath" 2>/dev/null; then
                printSuccess "$PROMPT_TABLE_DELETION_DONE"
            else
                printError "$PROMPT_TABLE_DELETION_ERROR"
            fi
        else
            printWarning "$PROMPT_TABLE_DELETION_CANCELLED"
        fi
    else
        printError "$PROMPT_INVALID_INPUT"
    fi
    echo "$tableName"
    tableMenu
}

dropTable
