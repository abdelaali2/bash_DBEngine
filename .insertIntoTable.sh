#!/usr/bin/env bash

DBinAction=$1

# TODO: check logic here & refactor the code more
function insertIntoTable() {
    sourceFile "$SCRIPT_LIST_TABLES" "$DBinAction" "skipTableMenu"

    readValidName "$PROMPT_READ_TABLE_NAME"
    tableName=$(retrieveValidatedInput)

    tablePath="$DBinAction/$tableName"

    until checkTableExistance "$tablePath"; do
        readValidName "$PROMPT_READ_TABLE_NAME"
        tableName=$(retrieveValidatedInput)

        tablePath="$DBinAction/$tableName"
    done

    metaTablePath="$DBinAction/.$tableName.meta"

    numOfColumns=$(awk 'END{print NR}' "${metaTablePath}")
    for i in $(seq 2 "$numOfColumns"); do

        colName=$(
            awk -F "$DATA_SEPARATOR" '{ if(NR == '"$i"') print $1}' "${metaTablePath}"
        )
        colType=$(
            awk -F "$DATA_SEPARATOR" '{ if(NR == '"$i"') print $2}' "${metaTablePath}"
        )
        isPK=$(
            awk -F "$DATA_SEPARATOR" '{ if(NR == '"$i"') print $3}' "${metaTablePath}"
        )

        data=$(readPlainText "$colName ($colType):   ")

        numericInputHandler
        PKHandler

        row+=$data
        if [ "$i" -lt "$numOfColumns" ]; then
            row+=$DATA_SEPARATOR
        fi

    done

    insertData "$row"
    row=""

    tableMenu
}

function numericInputHandler() {
    if [[ "$colType" == "$DATA_INTEGER" ]]; then
        readValidNumeric "$colName ($colType):  " "$data"
        data=$(retrieveValidatedInput)
    fi
}

function PKHandler() {
    if [[ "$isPK" == true ]]; then
        until applyPKConstraints "$data"; do
            errorCode=$?
            data=""
            clear
            printRelevantPKErrors "$errorCode"
            data=$(readPlainText "$colName ($colType):  ")
            numericInputHandler
        done
    fi
}

function applyPKConstraints() {
    if ! checkPKDuplciation "$1"; then
        return 2
    fi

    if ! checkIfNotNull "$1"; then
        return 1
    fi

    return 0
}

function checkIfNotNull() {
    if [ -z "$1" ]; then
        return 1
    fi

    return 0
}

function checkPKDuplciation() {
    local result
    result=$(awk -v data="$1" -v i="$i" -v DATA_SEPARATOR="$DATA_SEPARATOR" '
		BEGIN {
			FS = DATA_SEPARATOR
			isDuplicate = "false"
		}
		NR != 1 {
			if (data == $(i-1)) {
				isDuplicate = "true"
				exit 1
			}
		}
		END {
			print isDuplicate
		}
	' "$tablePath")

    if [[ $result == true ]]; then
        return 1
    fi

    return 0
}

function printRelevantPKErrors() {
    case "$1" in
    1)
        printError "$PROMPT_PK_NULL_ERROR"
        ;;
    2)
        printError "$PROMPT_PK_DUPLICATE_ERROR"
        ;;
    esac
}

function insertData() {
    if echo -e "$1" >>"$tablePath"; then
        printSuccess "$PROMPT_DATA_INSERTION_DONE"
    else
        printError "$PROMPT_DATA_INSERTION_ERROR"
    fi
}

insertIntoTable
