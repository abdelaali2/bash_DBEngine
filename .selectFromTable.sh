#!/usr/bin/env bash

DBinAction=$1

function selectfromTable() {

    clear
    readValidName "$PROMPT_READ_TABLE_NAME"
    tableName=$(retrieveValidatedInput)

    tablePath="$DBinAction/$tableName"

    until checkTableExistance "$tablePath"; do
        select input in "Select All" "Select Entire Column" "Select Entire Row" "Select Certain Value" "$RETURN"; do
            case $input in

            "Select All")
                typeset -i chkData
                chkData=$(cat $PWD/"./${tableName}" | wc -l)
                if [[ chkData -gt 1 ]]; then
                    cat $PWD/"./${tableName}" | more
                else
                    echo "Empty Set"
                fi
                echo "Press Eneter to return back to Select Menu"
                read cont
                selectfromTable
                ;;
            "Select Entire Column")
                typeset -i listofCol
                typeset -i selectedCol

                echo -e "The existing Columns are: \n======================="
                awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
                listofCol=$( (awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l))

                read -p "Enter the No. of the Column you want to Select: " selectedCol
                case ${selectedCol} in
                +([1-9]))
                    if [[ $selectedCol -le $listofCol ]]; then
                        header=$(sed -n '1p' ./${tableName} | awk -F: -v grab=$selectedCol '{print $grab}')
                        result=$(awk -F: -v grab=$selectedCol '{if (NR>1) print $grab}' ./${tableName})
                        if [[ -z $result ]]; then
                            echo $header
                            echo "***Empty Set***"
                        else
                            echo $header
                            awk -F: -v grab=$selectedCol '{if (NR>1) print $grab}' ./${tableName}
                        fi
                        echo "Press Eneter to return back to Select Menu"
                        read cont
                        selectfromTable
                    else
                        echo -e "Invalid Column No.!\nReturning back to Select Menu"
                        sleep 3
                        selectfromTable
                    fi
                    ;;
                *)
                    clear
                    echo -e "${STYLE_ON_IRED}$PROMPT_INVALID_INPUT${STYLE_NC}"
                    selectfromTable
                    ;;
                esac
                ;;
            "Select Entire Row")
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

                        echo "Press Eneter to return back to Select Menu"
                        read cont
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
            "Select Certain Value")
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
                        echo "Press Eneter to return back to Select Menu"
                        read cont
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
    done

    tableMenu
}
