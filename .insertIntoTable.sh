#!/usr/bin/env bash

DBinAction=$1

function insertIntoTable() {
    # shellcheck disable=SC1091
    # shellcheck disable=SC1090
    source "$SCRIPT_LIST_TABLES" "$DBinAction" "skipTableMenu"

    tableName=$(readTableName "$PROMPT_READ_TABLE_NAME")

    tablePath="$DBinAction/$tableName"

    until checkTableExistance "$tablePath"; do
        tableName=$(readTableName "$PROMPT_READ_TABLE_NAME")
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

        if [[ "$colType" == "$DATA_INTEGER" ]]; then
            handleIntegerScenario "$data"
        fi

        if [[ "$isPK" == true ]]; then
            handlePKScenario "$data"
        fi

        row+=$data
        if [ "$i" -lt "$numOfColumns" ]; then
            row+=$DATA_SEPARATOR
        fi

    done

    insertData "$data"

    row=""

    tableMenu
}

function handleIntegerScenario() {
    until numberValidator "$1"; do
        clear
        printError "$PROMPT_INVALID_INPUT $PROMPT_INVALID_DATATYPE_ERROR ($colType)"
        data=$(readPlainText "$colName ($colType): \t")
    done
}

function handlePKScenario() {
    until applyPKConstraints "$1"; do
        clear
        errorCode=$(applyPKConstraints "$1")
        case "$errorCode" in
        1)
            printError "$PROMPT_PK_DUPLICATE_ERROR"
            ;;
        2)
            printError "$PROMPT_PK_NULL_ERROR"
            ;;
        esac
        data=$(readPlainText "$colName ($colType): \t")
    done
}

function applyPKConstraints() {
    if checkPKDuplciation "$1"; then
        return 2
    fi

    if checkIfNull "$1"; then
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
    isDuplicatePK=false

    awk -v data="$1" -v i="$i" -v isDuplicatePK="$isDuplicatePK" -v DATA_SEPARATOR="$DATA_SEPARATOR" '
		BEGIN {
			FS = DATA_SEPARATOR
			ORS = " "
		}
		NR != 1 {
			if (data == $(i-1)) {
				isDuplicatePK="true"
			}
		}
	' "$tablePath"

    if [[ $isDuplicatePK == true ]]; then
        return 1
    fi

    return 0
}

function insertData() {
    if echo -e "$1" >>"$tablePath"; then
        printSuccess "$PROMPT_PK_DATA_INSERTION_DONE"
    else
        printError "$PROMPT_DATA_INSERTION_ERROR"
    fi
}

insertIntoTable
