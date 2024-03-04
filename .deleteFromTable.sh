#!/usr/bin/env bash

DBinAction=$1

function deleteFromTable() {
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

    select input in "$DELETE_TABLE" "$DELETE_ENTIRE_ROW" "$DELETE_CERTAIN_VALUES" "$RETURN"; do
        case $input in
        "$DELETE_TABLE")
            deleteTableData
            ;;
        "$DELETE_ENTIRE_ROW")
            typeset -i listofCol
            typeset -i selectedCol
            typeset -i delDone
            echo -e "The existing Columns are: \n======================="
            awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
            listofCol=$( (awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l))
            echo "Enter the No. of the Column you want to Delete from: "
            echo "Note: range from 1:99"
            read -n 2 selectedCol
            case ${selectedCol} in
            +([1-9]|[1-9][0-9]))
                if [[ $selectedCol -le $listofCol ]]; then
                    ((selectedCol++))
                    sed -n ${selectedCol}p ./.${tableName}_metaData | grep int >/dev/null
                    let ifInt=$?
                    ((selectedCol--))
                    if [[ ifInt -eq 0 ]]; then
                        echo -e "You choose an Integer type Column.\nPlease enter the No. you want to Delete"
                        read requiredData
                        case ${requiredData} in
                        +([0-9]))
                            index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1)
                            indexlist=$(awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l)
                            if [[ -z $index ]]; then
                                echo "***Empty Set***"
                            else
                                let decrement=0
                                echo "Value existing in "$indexlist" records."
                                for ((i = 1; i <= $indexlist; i++)); do
                                    line=$(echo $index | cut -d' ' -f$i)
                                    if [[ $i -gt 1 ]]; then
                                        for ((j = 1; j <= decrement; j++)); do
                                            ((line--))
                                        done
                                    fi
                                    echo $line
                                    sed -in ${line}d ./${tableName}
                                    delDone=$?
                                    if [[ delDone -eq 0 ]]; then
                                        echo "Row Deleted Successfully"
                                        ((decrement++))
                                    else
                                        echo "Error: Delete Aborted!"
                                    fi
                                done
                            fi
                            ;;
                        *)
                            echo -e "Invalid Entry!\nReturning back to Delete Menu"
                            sleep 3
                            deleteTable
                            ;;
                        esac
                    else
                        sed -n ${selectedCol}p ./.${tableName}_metaData | grep string >/dev/null
                        let ifString=$?
                        if [[ ifString -eq 0 ]]; then
                            echo -e "You choose a String type Column.\nPlease enter the word you want to Delete"
                            read requiredData
                            index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1)
                            indexlist=$(awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l)
                            if [ -z $index ]; then
                                echo "***Empty Set***"
                            else
                                let decrement=0
                                echo "Value existing in "$indexlist" records."
                                for ((i = 1; i <= $indexlist; i++)); do
                                    line=$(echo $index | cut -d' ' -f$i)
                                    if [[ $i -gt 1 ]]; then
                                        for ((j = 1; j <= decrement; j++)); do
                                            ((line--))
                                        done
                                    fi
                                    echo $line
                                    sed -in ${line}d ./${tableName}
                                    delDone=$?
                                    if [[ delDone -eq 0 ]]; then
                                        echo "Row Deleted Successfully"
                                        ((decrement++))
                                    else
                                        echo "Error: Delete Aborted!"
                                    fi
                                done
                            fi
                        fi

                    fi

                    echo "Press Eneter to return back to Delete Menu"
                    read cont
                    deleteTable
                else
                    echo -e "Invalid Column No.!\nReturning back to Delete Menu"
                    sleep 3
                    deleteTable
                fi
                ;;
            *)
                echo -e "Invalid Column No.!\nReturning back to Delete Menu"
                sleep 3
                deleteTable
                ;;
            esac
            ;;

        "$DELETE_CERTAIN_VALUES")
            typeset -i listofCol
            typeset -i selectedCol
            typeset -i delDone
            balnk=''
            echo -e "The existing Columns are: \n======================="
            awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
            listofCol=$( (awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l))
            echo "Enter the No. of the Column you want to Delete from: "
            echo "Note: range from 1:99"
            read -n 2 selectedCol
            case ${selectedCol} in
            +([1-9]|[1-9][0-9]))
                if [[ $selectedCol -le $listofCol ]]; then
                    ((selectedCol++))
                    sed -n ${selectedCol}p ./.${tableName}_metaData | grep int >/dev/null
                    let ifInt=$?
                    ((selectedCol--))
                    if [[ ifInt -eq 0 ]]; then
                        echo -e "You choose an Integer type Column.\nPlease enter the No. you want to Delete"
                        read requiredData
                        case ${requiredData} in
                        +([0-9]))
                            index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1)
                            indexlist=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l)
                            if [ -z "$index" ]; then
                                echo "***Empty Set***"
                            else
                                echo -e "Value existing in "$indexlist" records.\n======================="
                                echo $index
                                read -p "Enter the No. of the line you want to delete from it: " line
                                sed -in "$line s/$requiredData/$blank/" ./${tableName}
                                delDone=$?
                                if [[ delDone -eq 0 ]]; then
                                    echo "Value Deleted Successfully"
                                else
                                    echo "Error: Delete Aborted!"
                                fi
                            fi
                            ;;
                        *)
                            echo -e "Invalid Entry!\nReturning back to Delete Menu"
                            sleep 3
                            deleteTable
                            ;;
                        esac
                    else
                        sed -n ${selectedCol}p ./.${tableName}_metaData | grep string >/dev/null
                        let ifString=$?
                        if [[ ifString -eq 0 ]]; then
                            echo -e "You choose a String type Column.\nPlease enter the word you want to Delete"
                            read requiredData
                            index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1)
                            indexlist=$(awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l)
                            if [ -z "$index" ]; then
                                echo "***Empty Set***"
                            else
                                echo -e "Value existing in "$indexlist" records.\n======================="
                                echo $index
                                read -p "Enter the No. of the line you want to delete from it: " line
                                sed -in "$line s/$requiredData/$blank/" ./${tableName}
                                delDone=$?
                                if [[ delDone -eq 0 ]]; then
                                    echo "Value Deleted Successfully"
                                else
                                    echo "Error: Delete Aborted!"
                                fi
                            fi
                        fi

                    fi

                    echo "Press Eneter to return back to Delete Menu"
                    read cont
                    deleteTable
                else
                    echo -e "Invalid Column No.!\nReturning back to Delete Menu"
                    sleep 3
                    deleteTable
                fi
                ;;
            esac
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

function deleteTableData() {

    if confirmChoice "$tableName:\n\t $PROMPT_DATA_DELETION_CONFIRM"; then
        set -x
        header=$(getTableSchema)
        if echo "$header" >"$tablePath"; then
            printSuccess "$PROMPT_DATA_DELETION_DONE"
        else
            printError "$PROMPT_DATA_DELETION_ERROR"
        fi
    else
        printWarning "$PROMPT_DATA_DELETION_CANCELLED"
    fi
    set +x

    pauseExecution
    tableMenu
}

function getTableSchema() {
    local schema
    schema=$(sed -n 1p "$tablePath")
    echo "$schema"
}

deleteFromTable
