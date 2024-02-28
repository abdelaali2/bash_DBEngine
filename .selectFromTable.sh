#!/usr/bin/env bash

DBinAction=$1

function selectfromTable() {
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
        "$SELECT_ENTIRE_ROW")
            typeset -i listofCol
            typeset -i selectedCol

            echo -e "The existing Columns are: \n======================="
            awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
            listofCol=$( (awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l))

            read -p "Enter the No. of the Column you want to Select from: " selectedCol
            case ${selectedCol} in
            +([1-9]))
                if [[ $selectedCol -le $listofCol ]]; then
                    selectedCol=$selectedCol+1
                    sed -n ${selectedCol}p ./.${tableName}_metaData | grep int >/dev/null
                    let ifInt=$?
                    if [[ ifInt -eq 0 ]]; then
                        echo -e "You choose an Integer type Column.\nPlease enter the No. you want to search for"
                        read requiredData
                        index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1)
                        if [ -z $index ]; then
                            echo "***Empty Set***"
                        else
                            for i in $index; do
                                sed -n ${i}p ./${tableName}
                            done
                        fi
                    else
                        sed -n ${selectedCol}p ./.${tableName}_metaData | grep string >/dev/null
                        let ifString=$?
                        if [[ ifString -eq 0 ]]; then
                            echo -e "You choose a String type Column.\nPlease enter the word you want to search for"
                            read requiredData
                            index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -iwn $requiredData | cut -d: -f1)

                            if [ -z $index ]; then
                                echo "***Empty Set***"
                            else
                                for i in $index; do
                                    sed -n ${i}p ./${tableName}
                                done
                            fi
                        fi

                    fi

                    pauseExecution
                    selectfromTable
                else
                    echo -e "Invalid Column No.!\nReturning back to Select Menu"
                    sleep 3
                    selectfromTable
                fi
                ;;
            *)
                echo -e "Invalid Column No.!\nReturning back to Select Menu"
                sleep 3
                selectfromTable
                ;;
            esac
            ;;
        "$SELECT_CERTAIN_VALUES")
            typeset -i listofCol
            typeset -i selectedCol

            echo -e "The existing Columns are: \n======================="
            awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
            listofCol=$( (awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l))

            read -p "Enter the No. of the Column you want to Select from: " selectedCol
            case ${selectedCol} in
            +([1-9]))
                if [[ $selectedCol -le $listofCol ]]; then
                    selectedCol=$selectedCol+1
                    sed -n ${selectedCol}p ./.${tableName}_metaData | grep int >/dev/null
                    let ifInt=$?
                    selectedCol=$selectedCol-1
                    if [[ ifInt -eq 0 ]]; then
                        echo -e "You choose an Integer type Column.\nPlease enter the No. you want to search for"
                        read requiredData
                        result=$(awk -F: -v grab=$selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData)
                        resultLine=$(echo $result | awk -F: -v RS=' ' '{print $1}')
                        if [ -z $result ]; then
                            echo "***Empty Set***"
                        else
                            echo "========================================="
                            echo "  value $requiredData exists in line"
                            echo -e "\t"$resultLine
                            echo "========================================="
                        fi
                    else
                        selectedCol=$selectedCol+1
                        sed -n ${selectedCol}p ./.${tableName}_metaData | grep string >/dev/null
                        let ifString=$?
                        selectedCol=$selectedCol-1
                        if [[ ifString -eq 0 ]]; then
                            echo -e "You choose a String type Column.\nPlease enter the word you want to search for"
                            read requiredData
                            result=$(awk -F: -v grab=$selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData)
                            resultLine=$(echo $result | awk -F: -v RS=' ' '{print $1}')
                            if [ -z "$result" ]; then
                                echo "***Empty Set***"
                            else
                                echo "========================================="
                                echo "  value $requiredData exists in line"
                                echo -e "\t"$resultLine
                                echo "========================================="
                            fi
                        fi

                    fi
                    pauseExecution
                    selectfromTable
                else
                    echo -e "Invalid Column No.!\nReturning back to Select Menu"
                    sleep 3
                    selectfromTable
                fi
                ;;
            *)
                echo -e "Invalid Column No.!\nReturning back to Select Menu"
                sleep 3
                selectfromTable
                ;;
            esac
            ;;
        "$RETURN")
            tableMenu
            ;;
        esac
    done

    tableMenu
}

function selectAll() {
    if checkNotEmpty "$tablePath"; then
        more "$tablePath"
    fi

    pauseExecution

    clear
    tableMenu
}

function selectEntireColumn() {
    queryMetaTable "$metaTablePath"

    readValidNumeric "$PROMPT_SELECT_COL"
    selectedCol=$(retrieveValidatedInput)

    until [[ $selectedCol -le $numOfCols ]]; do
        printError "$PROMPT_COL_OUTBOUND_ERROR"
        readValidNumeric "$PROMPT_SELECT_COL"
        selectedCol=$(retrieveValidatedInput)
    done

    queryDataTable "$selectedCol" "$tablePath"
    pauseExecution

    tableMenu
}

function queryMetaTable() {
    echo -e "$PROMPT_EXISTING_COLS"
    columns=$(
        awk -F: '
            NR > 1 {
                print NR-1 " - " $1
            }
        ' "$1"
    )

    numOfCols=$(echo "$columns" | wc -l)

    printList "$columns"
}

function queryDataTable() {
    result=$(awk -F: -v grab="$1" 'NR>1 {
            print $grab
        }' "$2")

    header=$(awk -F: -v grab="$1" 'NR==1 {
            print $grab
        }' "$2")

    printSuccess "$header"
    if checkNotEmpty "$result"; then
        echo "$result"
    fi
}

selectfromTable
