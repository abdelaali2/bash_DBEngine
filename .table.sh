#!/bin/bash

shopt -s extglob
export LC_COLLATE=C
Red='\033[0;31m'
Green='\033[0;32m'
NC='\033[0m'
Yellow='\033[0;33m'
On_IGreen='\033[0;102m'
On_IRed='\033[0;101m'
On_IYellow='\033[0;103m'

function tableMenu() {
	select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Exit" "Return"; do
		case $choice in
		"Create Table")
			createTable
			;;
		"List Tables")
			listTables
			;;
		"Drop Table")
			dropTable
			;;
		"Insert into Table")
			insert
			;;
		"Select From Table") ;;

		\
			"Delete From Table") ;;

		"Update Table") ;;

		"Exit")
			exit
			;;
		"Return")
			clear
			cd ../..
			mainMenu
			;;
		*)
			echo -e "${On_IRed}Please choose from the options available!${NC}\n"
			tableMenu
			;;
		esac
	done

}

function listTables() {
	clear
	echo -e "${On_IGreen}List of the tables exist:${NC}\n"
	ls . 2>>/dev/null
	echo -e "\n"
	tableMenu
}

function dropTable() {
	read -e -p "Enter table name: " tableName
	case $tableName in
	+([a-zA-Z]*))
		echo -e "${On_IYellow}Are you sure you want to delete table ${tableName}${NC}"
		select ch in "Yes" "No"; do
			case $ch in
			"Yes")
				rm "${tableName}" 2>>/dev/null
				if [ $? -eq 0 ]; then
					echo -e "Table is dropped\n"
					rm "${tableName}_metaData" 2>>/dev/null
				else
					echo -e "Error dropping the table\n"
				fi
				break
				;;
			"No")
				break
				;;
			*)
				echo "Please choose from the options avaliable!"
				;;
			esac
		done
		;;
	*)
		clear
		echo -e "Invalid input!\n"
		;;
	esac
	tableMenu
}

function createTable() {
	#asking for table name

	read -e -p "Please Enter table name: " tableName
	tableName=$(echo ${tableName// /_})
	case $tableName in
	+([a-zA-Z]*))
		test -f ${tableName} && echo -e "${tableName} is already exist" && tableMenu
		;;
	*)
		break
		;;
	esac

	case "${tableName}" in
	+([a-zA-Z]*))

		#asking for no. of col
		read -p "Please enter number of columns: " colNumber
		case ${colNumber} in
		+([1-9]))
			counter=1
			sep=":"
			newLine="\n"
			primaryKey=""
			metaData="Field"$sep"Type"$sep"key"
			while [ ${counter} -le ${colNumber} ]; do
				#asking for the name of the column
				read -p "Please enter the name of column no.${counter}: " columnName
				columnName=$(echo ${columnName// /_})
				case "${columnName}" in
				+([a-zA-Z]*))
					#asking for the type of the column
					echo "choose type of column ${columnName}"
					select ch in "integer" "string"; do
						case $ch in
						"integer")
							colType="int"
							break
							;;
						"string")
							colType="string"
							break
							;;
						*)
							echo "Invalid choice! Please choose from the options available"
							;;
						esac
					done
					;;
				*)
					echo "Invalid name"
					createTable
					break
					;;
				esac

				#asking for pk
				if [ -z ${primaryKey} ]; then
					echo -e "Do you want this column to be the pk?"
					select ch in "Yes" "No"; do
						case $ch in
						"Yes")
							primaryKey="PK"
							metaData+=$newLine$columnName$sep$colType$sep$primaryKey
							break
							;;
						"No")
							metaData+=$newLine$columnName$sep$colType$sep""
							break
							;;
						*)
							echo "Invalid choice! Please choose from the options available"
							;;
						esac
					done
				else
					metaData+=$newLine$columnName$sep$colType$sep""

				fi

				if [ $counter -eq $colNumber ]; then
					tableHeader=$tableHeader$columnName
				else
					tableHeader=$tableHeader$columnName$sep
				fi

				((counter++))

			done #end of while

			touch ".${tableName}_metaData"
			touch "${tableName}"
			echo -e $metaData >>".${tableName}_metaData"
			echo -e $tableHeader >>${tableName}
			if [ $? -eq 0 ]; then
				echo "Table Created Successfully"
				tableMenu
			else
				echo "Error Creating Table $tableName"
				tableMenu
			fi
			;;
		*)
			clear
			echo -e "Invalid input, please enter a numeric input\n"
			createTable
			;;
		esac
		;;
	*)
		clear
		echo -e "Invalid Naming Convention table name should not start with a number or a specail character\n"
		createTable
		;;
	esac
}

function insert() {
	read -e -p "Enter table name: " tName
	tName=$(echo ${tName// /_})
	case $tName in
	+([a-zA-Z]*))
		test ! -f ${tName} && echo -e "${tName} does not exist" && tableMenu
		;;
	*)
		echo "Invalid input!"
		tableMenu
		;;
	esac

	numberOfColumns=$(awk 'END{print NR}' ".${tName}_metaData")
	sep=":"
	newLine="\n"
	for ((i = 2; i <= ${numberOfColumns}; i++)); do
		#loop 3ala el meta data we b3mlohm store fe var 3shan a3ml check lama el user y3ml insert
		columnName=$(awk 'BEGIN{FS=":"}{ if(NR == '${i}') print $1}' ".${tName}_metaData")
		columnType=$(awk 'BEGIN{FS=":"}{if(NR == '${i}') print $2}' ".${tName}_metaData")
		columnKey=$(awk 'BEGIN{FS=":"}{if(NR == '${i}') print $3}' ".${tName}_metaData")

		#habd2 as2l el user yd5l el data
		read -e -p "Enter data in the ${columnName} column (${columnType}): " data

		#habd2 a3ml check 3ala el data
		if [ "${columnType}" = "int" ]; then
			until [[ $data =~ ^[0-9]*$ ]]; do
				echo -e "Invalid input, int data type must be numbers!"
				read -e -p "Enter the data in ${columnName} (${columnType}): " data
			done
		fi

		if [ "${columnKey}" = "PK" ]; then

			until ! [[ ($data =~ ^[$(awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' ${tName})]$ || -z ${data}) ]]; do
				echo -e "invalid input for Primary Key , Primary key should be unique and not null!\n"
				read -e -p "Enter the data in ${columnName} (${columnType}): " data
			done
		fi

		if [ ${i} -eq ${numberOfColumns} ]; then
			row=$row$data$newLine
		else
			row=$row$data$sep
		fi

	done

	echo -e $row >>$tName
	if [ $? -eq 0 ]; then
		echo -e "Data Inserted Successfully\n"
	else
		echo -e "Error Inserting Data into Table ${tName}\n"
	fi
	row=""
	tableMenu
}

function selectfromTable() {

	clear
	read -p "Please Enter table name: " tableName
	tableName=`echo ${tableName// /_}`

	if [ -f "./${tableName}" ]
	then
		select input in "Select All" "Select Entire Column" "Select Entire Row" "Select Certain Value" "Return"
		do
			case $input in
			
				"Select All")
					typeset -i chkData
					chkData=`cat $PWD/"./${tableName}" | wc -l`
					if [[ chkData -gt 1 ]]
					then
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
					listofCol=`(awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l)`
					
					read -p "Enter the No. of the Column you want to Select: " selectedCol
					case ${selectedCol} in
						+([1-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								header=`sed -n '1p' ./${tableName} | awk -F: -v grab=$selectedCol '{print $grab}'`
								result=`awk -F: -v grab=$selectedCol '{if (NR>1) print $grab}' ./${tableName}`
								if [[ -z $result ]]
									then
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
							echo -e "Invalid input!, please enter a numeric input\n"
							selectfromTable
						;;
					esac
				;;
				"Select Entire Row")
					typeset -i listofCol
					typeset -i selectedCol

					echo -e "The existing Columns are: \n======================="
					awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
					listofCol=`(awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l)`
					
					read -p "Enter the No. of the Column you want to Select from: " selectedCol
					case ${selectedCol} in
						+([1-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								selectedCol=$selectedCol+1
								sed -n ${selectedCol}p ./.${tableName}_metaData | grep int > /dev/null
								let ifInt=$?
								if [[ ifInt -eq 0 ]]
								then
									echo -e "You choose an Integer type Column.\nPlease enter the No. you want to search for"
									read requiredData
									index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1`
									if [ -z $index ]
									then
										echo "***Empty Set***"
									else
										for i in $index
										do
											sed -n ${i}p ./${tableName}
										done
									fi
								else
									sed -n ${selectedCol}p ./.${tableName}_metaData | grep string > /dev/null
									let ifString=$?
									if [[ ifString -eq 0 ]]
									then
										echo -e "You choose a String type Column.\nPlease enter the word you want to search for"
										read requiredData
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -iwn $requiredData | cut -d: -f1`
									
										if [ -z $index ]
										then
											echo "***Empty Set***"
										else
											for i in $index
											do
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
					listofCol=`(awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l)`
					
					read -p "Enter the No. of the Column you want to Select from: " selectedCol
					case ${selectedCol} in
						+([1-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								selectedCol=$selectedCol+1
								sed -n ${selectedCol}p ./.${tableName}_metaData | grep int > /dev/null
								let ifInt=$?
								selectedCol=$selectedCol-1
								if [[ ifInt -eq 0 ]]
								then
									echo -e "You choose an Integer type Column.\nPlease enter the No. you want to search for"
									read requiredData
									result=`awk -F: -v grab=$selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData`
									resultLine=`echo $result | awk -F: -v RS=' ' '{print $1}'` 
									if [ -z $result ]
									then
										echo "***Empty Set***"
									else
										echo "========================================="
										echo "  value $requiredData exists in line"
										echo -e "\t"$resultLine
										echo "========================================="
									fi
								else
									selectedCol=$selectedCol+1
									sed -n ${selectedCol}p ./.${tableName}_metaData | grep string > /dev/null
									let ifString=$?
									selectedCol=$selectedCol-1
									if [[ ifString -eq 0 ]]
									then
										echo -e "You choose a String type Column.\nPlease enter the word you want to search for"
										read requiredData
										result=`awk -F: -v grab=$selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData`
										resultLine=`echo $result | awk -F: -v RS=' ' '{print $1}'` 
										if [ -z "$result" ]
										then
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
				"Return")
					tableMenu
				;;
			esac
		done
	else
		
		echo -e "Invalid table name!\nReturning back to Select Menu"
		sleep 3
		selectfromTable
	fi

}

function deleteTable () {
	
	clear
	read -p "Please Enter table name: " tableName
	tableName=`echo ${tableName// /_}`

	if [ -f "./${tableName}" ]
	then
		select input in "Delete all data" "Delete Entire Row" "Delete Certain Value" "Return"
		do
			case $input in
				"Delete all data")
					typeset -i chkData
					chkData=`cat $PWD/"./${tableName}" | wc -l`
					if [[ chkData -gt 1 ]]
					then
						cat /dev/null > $PWD/"./${tableName}"
						let delDone=$?
						if [[ delDone -eq 0 ]]
						then
							echo "Data Deleted Successfully"
						else
							echo "Error: Delete Aborted!"
						fi
					else
						echo "Empty Set"
					fi
					echo "Press Eneter to return back to Delete Menu"
					read cont
					deleteTable
				;;
				"Delete Entire Row")
					typeset -i listofCol
					typeset -i selectedCol
					typeset -i delDone
					echo -e "The existing Columns are: \n======================="
					awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
					listofCol=`(awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l)`
					echo "Enter the No. of the Column you want to Delete from: "
					echo "Note: range from 1:99"
					read -n 2 selectedCol
					case ${selectedCol} in
						+([1-9]|[1-9][0-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								((selectedCol++))
								sed -n ${selectedCol}p ./.${tableName}_metaData | grep int > /dev/null
								let ifInt=$?
								((selectedCol--))
								if [[ ifInt -eq 0 ]]
								then
									echo -e "You choose an Integer type Column.\nPlease enter the No. you want to Delete"
									read requiredData
									case ${requiredData} in
									+([0-9]))
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1`
										indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l`
										if [[ -z $index ]]
										then
											echo "***Empty Set***"
										else
											let decrement=0
											echo "Value existing in "$indexlist" records."
											for (( i=1; i<=$indexlist; i++))
											do
												line=`echo $index | cut -d' ' -f$i `
												if [[ $i -gt 1 ]]
												then
													for ((j=1;j<=decrement;j++))
													do
														((line--))
													done
												fi
												echo $line
												sed -in ${line}d ./${tableName}
												delDone=$?
												if [[ delDone -eq 0 ]]
												then
													echo "Row Deleted Successfully"
													(( decrement++ ))
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
									sed -n ${selectedCol}p ./.${tableName}_metaData | grep string > /dev/null
									let ifString=$?
									if [[ ifString -eq 0 ]]
									then
										echo -e "You choose a String type Column.\nPlease enter the word you want to Delete"
										read requiredData
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1`
										indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l`
										if [ -z $index ]
										then
											echo "***Empty Set***"
										else
											let decrement=0
											echo "Value existing in "$indexlist" records."
											for (( i=1; i<=$indexlist; i++))
											do
												line=`echo $index | cut -d' ' -f$i `
												if [[ $i -gt 1 ]]
												then
													for ((j=1;j<=decrement;j++))
													do
														((line--))
													done
												fi
												echo $line
												sed -in ${line}d ./${tableName}
												delDone=$?
												if [[ delDone -eq 0 ]]
												then
													echo "Row Deleted Successfully"
													(( decrement++ ))
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

				"Delete Certain Value")
					typeset -i listofCol
					typeset -i selectedCol
					typeset -i delDone
					balnk=''
					echo -e "The existing Columns are: \n======================="
					awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
					listofCol=`(awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l)`
					echo "Enter the No. of the Column you want to Delete from: "
					echo "Note: range from 1:99"
					read -n 2 selectedCol
					case ${selectedCol} in
						+([1-9]|[1-9][0-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								((selectedCol++))
								sed -n ${selectedCol}p ./.${tableName}_metaData | grep int > /dev/null
								let ifInt=$?
								((selectedCol--))
								if [[ ifInt -eq 0 ]]
								then
									echo -e "You choose an Integer type Column.\nPlease enter the No. you want to Delete"
									read requiredData
									case ${requiredData} in
									+([0-9]))
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1`
										indexlist=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l`
										if [ -z "$index" ]
										then
											echo "***Empty Set***"
										else
											echo -e "Value existing in "$indexlist" records.\n======================="
											echo $index
											read -p "Enter the No. of the line you want to delete from it: " line
											sed -in "$line s/$requiredData/$blank/" ./${tableName}
											delDone=$?
											if [[ delDone -eq 0 ]]
											then
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
									sed -n ${selectedCol}p ./.${tableName}_metaData | grep string > /dev/null
									let ifString=$?
									if [[ ifString -eq 0 ]]
									then
										echo -e "You choose a String type Column.\nPlease enter the word you want to Delete"
										read requiredData
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1`
										indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l`
										if [ -z "$index" ]
										then
											echo "***Empty Set***"
										else
											echo -e "Value existing in "$indexlist" records.\n======================="
											echo $index
											read -p "Enter the No. of the line you want to delete from it: " line
											sed -in "$line s/$requiredData/$blank/" ./${tableName}
											delDone=$?
											if [[ delDone -eq 0 ]]
											then
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
						*)
							echo -e "Invalid Column No.!\nReturning back to Delete Menu"
							sleep 3
							deleteTable
						;;
					esac
				;;

				"Return")
					tableMenu
				;;
			esac

		done

	else
		
		echo -e "Invalid table name!\nReturning back to Delete Menu"
		sleep 3
		deleteTable
	fi


}


function updateTable (){

	clear
	read -p "Please Enter table name: " tableName
	tableName=`echo ${tableName// /_}`
	if [ -f "./${tableName}" ]
	then
		select input in "Update Value" "Return"
		do
			case $input in
			"Update Value")
				echo "Table: "$tableName
				echo -e "The existing Columns are: \n======================="
				awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
				listofCol=`(awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l)`
				echo "Enter the No. of the Column you want to Update: "
				echo "Note: range from 1:99"
				read -n 2 selectedCol
				case ${selectedCol} in
				+([1-9]|[1-9][0-9]))
					if [[ $selectedCol -le $listofCol ]]
					then
					
						((selectedCol++))
						sed -n ${selectedCol}p ./.${tableName}_metaData | grep int > /dev/null
						let ifInt=$?
						sed -n ${selectedCol}p ./.${tableName}_metaData | grep string > /dev/null
						let ifString=$?
						sed -n ${selectedCol}p ./.${tableName}_metaData | grep PK > /dev/null
						let ifPK=$?
						((selectedCol--))

						if [[ ifInt -eq 0 ]]
						then
							echo -e "You choose an Integer type Column."
							if [[ ifPK -eq 0 ]]
							then 
								echo "This is the PK of the Table"
								read -p "Enter the data you want to Update: "  requiredData
								index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1`
								indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l`
								if [ -z "$index" ]
								then
									echo "***Empty Set***"
									sleep 3
									updateTable
								else
									echo -e "Value existing in "$indexlist" records.\n======================="
									echo $index
									read -p "Enter the No. of the line you want to delete from it: " line
									let trueUpdate=0
									while [[ trueUpdate -eq 0 ]]
									do
										read -p "Enter the new No.: " newData
										awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $newData > /dev/null
										let ifFound=$?
										case $newData in
										+([0-9]))
											if [[ ifFound -eq 0 ]]
											then
												echo "Error: PK Repetition!"
											else
												sed -in "$line s/$requiredData/$newData/" ./${tableName}
												let upDone=$?
												if [[ upDone -eq 0 ]]
												then
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
								read -p "Enter the data you want to Update: "  requiredData
								index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1`
								indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l`
								if [ -z "$index" ]
								then
									echo "***Empty Set***"
									sleep 3
									updateTable
								else
									echo -e "Value existing in "$indexlist" records.\n======================="
									echo $index
									read -p "Enter the No. of the line you want to delete from it: " line
									let trueUpdate=0
									while [[ trueUpdate -eq 0 ]]
									do
										read -p "Enter the new No.: " newData
										case $newData in
										+([0-9]))
											sed -in "$line s/$requiredData/$newData/" ./${tableName}
											let upDone=$?
											if [[ upDone -eq 0 ]]
											then
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

						elif [[ ifString -eq 0 ]]
						then
							echo -e "You choose an String type Column."
							if [[ ifPK -eq 0 ]]
							then 
								echo "This is the PK of the Table"
								read -p "Enter the data you want to Update: "  requiredData
								index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1`
								indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l`
								if [ -z "$index" ]
								then
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
									while [ trueUpdate -eq 0 ]
									do
										if [[ ifFound -eq 0 ]]
										then
											echo "Error: PK Repetition!"
										else
											sed -in "$line s/$requiredData/$newData/" ./${tableName}
											let upDone=$?
											if [[ upDone -eq 0 ]]
											then
												echo "No. Updated Successfully"
												((trueUpdate++))
											else
												echo "Error: Update Aborted!"
											fi

										fi
									done
								fi
							else
								read -p "Enter the data you want to Update: "  requiredData
								index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1`
								indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l`
								if [ -z "$index" ]
								then
									echo "***Empty Set***"
									sleep 3
									updateTable
								else
									echo -e "Value existing in "$indexlist" records.\n======================="
									echo $index
									read -p "Enter the No. of the line you want to delete from it: " line

									let trueUpdate=0
									while [ trueUpdate -eq 0 ]
									do
										sed -in "$line s/$requiredData/$newData/" ./${tableName}
										let upDone=$?
										if [[ upDone -eq 0 ]]
										then
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
			"Return")
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
