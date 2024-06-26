#!/bin/bash
currentDB=$1

function tableMenu() {
	select choice in "$CREATE_TABLE" "$LIST_TABLES" "$DROP_TABLE" "$INSERT_INTO_TABLE" "$SELECT_FROM_TABLE" "$DELETE_FROM_TABLE" "$UPDATE_TABLE" "$EXIT" "$RETURN"; do
		case $choice in
		"$CREATE_TABLE")
			sourceFile "$SCRIPT_CREATE_TABLE" "$currentDB"
			;;
		"$LIST_TABLES")
			sourceFile "$SCRIPT_LIST_TABLES" "$currentDB"
			;;
		"$DROP_TABLE")
			sourceFile "$SCRITPT_DROP_TABLE" "$currentDB"
			;;
		"$INSERT_INTO_TABLE")
			sourceFile "$SCRIPT_INSERT_INTO_TABLE" "$currentDB"
			;;
		"$SELECT_FROM_TABLE")
			sourceFile "$SCRIPT_SELECT_FROM_TABLE" "$currentDB"
			;;

		"$DELETE_FROM_TABLE")
			sourceFile "$SCRIPT_DELETE_FROM_TABLE" "$currentDB"
			dropTable
			;;

		"$UPDATE_TABLE")
			updateTable
			;;

		"$EXIT")
			exit
			;;

		"$RETURN")
			clear
			mainMenu
			;;
		*)
			printError "$PROMPT_INVALID_INPUT"
			tableMenu
			;;
		esac
	done

}

function updateTable() {

	clear
	tableName=$(readInput "$PROMPT_READ_TABLE_NAME")
	if [ -f "./${tableName}" ]; then
		select input in "Update Value" "$RETURN"; do
			case $input in
			"Update Value")
				echo "Table: "$tableName
				echo -e "The existing Columns are: \n======================="
				awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
				listofCol=$( (awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l))
				echo "Enter the No. of the Column you want to Update: "
				echo "Note: range from 1:99"
				read -n 2 selectedCol
				case ${selectedCol} in
				+([1-9]|[1-9][0-9]))
					if [[ $selectedCol -le $listofCol ]]; then

						((selectedCol++))
						sed -n ${selectedCol}p ./.${tableName}_metaData | grep int >/dev/null
						let ifInt=$?
						sed -n ${selectedCol}p ./.${tableName}_metaData | grep string >/dev/null
						let ifString=$?
						sed -n ${selectedCol}p ./.${tableName}_metaData | grep PK >/dev/null
						let ifPK=$?
						((selectedCol--))

						if [[ ifInt -eq 0 ]]; then
							echo -e "You choose an Integer type Column."
							if [[ ifPK -eq 0 ]]; then
								echo "This is the PK of the Table"
								read -p "Enter the data you want to Update: " requiredData
								index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1)
								indexlist=$(awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l)
								if [ -z "$index" ]; then
									echo "***Empty Set***"
									sleep 3
									updateTable
								else
									echo -e "Value existing in "$indexlist" records.\n======================="
									echo $index
									read -p "Enter the No. of the line you want to delete from it: " line
									let trueUpdate=0
									while [[ trueUpdate -eq 0 ]]; do
										read -p "Enter the new No.: " newData
										awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $newData >/dev/null
										let ifFound=$?
										case $newData in
										+([0-9]))
											if [[ ifFound -eq 0 ]]; then
												echo "Error: PK Repetition!"
											else
												sed -in "$line s/$requiredData/$newData/" ./${tableName}
												let upDone=$?
												if [[ upDone -eq 0 ]]; then
													echo "No. Updated Successfully"
													((trueUpdate++))
												else
													echo "Error: Update Aborted!"
												fi

											fi
											;;
										*)
											echo -e "Invalid Entry!"
											;;
										esac
										sleep 3
									done
									echo "Press Eneter to return back to Update Menu"
									read cont
									updateTable
								fi
							else
								read -p "Enter the data you want to Update: " requiredData
								index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1)
								indexlist=$(awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l)
								if [ -z "$index" ]; then
									echo "***Empty Set***"
									sleep 3
									updateTable
								else
									echo -e "Value existing in "$indexlist" records.\n======================="
									echo $index
									read -p "Enter the No. of the line you want to delete from it: " line
									let trueUpdate=0
									while [[ trueUpdate -eq 0 ]]; do
										read -p "Enter the new No.: " newData
										case $newData in
										+([0-9]))
											sed -in "$line s/$requiredData/$newData/" ./${tableName}
											let upDone=$?
											if [[ upDone -eq 0 ]]; then
												echo "No. Updated Successfully"
												((trueUpdate++))
											else
												echo "Error: Update Aborted!"
											fi
											;;
										*)
											echo -e "Invalid Entry!"
											;;
										esac
										sleep 3
									done
									echo "Press Eneter to return back to Update Menu"
									read cont
									updateTable
								fi
							fi

						elif [[ ifString -eq 0 ]]; then
							echo -e "You choose an String type Column."
							if [[ ifPK -eq 0 ]]; then
								echo "This is the PK of the Table"
								read -p "Enter the data you want to Update: " requiredData
								index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1)
								indexlist=$(awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l)
								if [ -z "$index" ]; then
									echo "***Empty Set***"
									sleep 3
									updateTable
								else
									echo -e "Value existing in "$indexlist" records.\n======================="
									echo $index
									read -p "Enter the No. of the line you want to delete from it: " line
									read -p "Enter the new No.: " newData
									awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $newData
									let ifFound=$?
									let trueUpdate=0
									while [ trueUpdate -eq 0 ]; do
										if [[ ifFound -eq 0 ]]; then
											echo "Error: PK Repetition!"
										else
											sed -in "$line s/$requiredData/$newData/" ./${tableName}
											let upDone=$?
											if [[ upDone -eq 0 ]]; then
												echo "No. Updated Successfully"
												((trueUpdate++))
											else
												echo "Error: Update Aborted!"
											fi

										fi
									done
								fi
							else
								read -p "Enter the data you want to Update: " requiredData
								index=$(awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1)
								indexlist=$(awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l)
								if [ -z "$index" ]; then
									echo "***Empty Set***"
									sleep 3
									updateTable
								else
									echo -e "Value existing in "$indexlist" records.\n======================="
									echo $index
									read -p "Enter the No. of the line you want to delete from it: " line

									let trueUpdate=0
									while [ trueUpdate -eq 0 ]; do
										sed -in "$line s/$requiredData/$newData/" ./${tableName}
										let upDone=$?
										if [[ upDone -eq 0 ]]; then
											echo "No. Updated Successfully"
											((trueUpdate++))
										else
											echo "Error: Update Aborted!"
										fi

									done
								fi
							fi
						fi

					else
						echo -e "Invalid Column No.!\nReturning back to Update Menu"
						sleep 3
						updateTable
					fi
					;;
				*)
					echo -e "Invalid Column No.!\nReturning back to Update Menu"
					sleep 3
					updateTable
					;;
				esac
				;;
			"$RETURN")
				tableMenu
				;;
			esac

		done
	else

		echo -e "Invalid table name!\nReturning back to Update Menu"
		sleep 3
		updateTable
	fi
}

tableMenu
