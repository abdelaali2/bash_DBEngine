#!/bin/bash

shopt -s extglob
export LC_COLLATE=C
Red='\033[0;31m'
Green='\033[0;32m'
NC='\033[0m'
Yellow='\033[0;33m'
On_IGreen='\033[0;102m'
On_IRed='\033[0;101m'

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
		"Select From Table") 
			selectfromTable
		;;
		"Delete From Table") 
			deleteTable
		;;
		"Update Table")
			updateTable
		 ;;
		"Exit")
			exit
			;;
		"Return")
			clear
			cd ../..
			mainMenu
			;;
		*)
			echo -e "Please choose from the options available!\n"
			tableMenu
			;;
		esac
	done
}

function listTables() {
	clear
	echo -e "List of the tables exist:\n"
	ls . 2>>/dev/null
	echo -e "\n"
	tableMenu
}


function dropTable() {
	read -e -p "Enter table name: " tableName
	case $tableName in
	+([a-zA-Z]*))
		echo -e "${Yellow}Are you sure you want to delete table ${tableName}${NC}"
		select ch in "Yes" "No"; do
			case $ch in
			"Yes")
				rm "${tableName}" 2>>/dev/null
				if [ $? -eq 0 ]; then
					clear
					echo -e "${On_IGreen}Table is dropped\n${NC}"
					rm ".${tableName}_metaData" 2>>/dev/null
				else
					clear
					echo -e "${On_IRed}Error dropping the table\n${NC}"
				fi
				break
				;;
			"No")
				break
				;;
			*)
				echo -e "${On_IRed}Please choose from the options avaliable!${NC}"
				;;
			esac
		done
		;;
	*)
		clear
		echo -e "${On_IRed}Invalid input!\n${NC}"
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
		test -f ${tableName} && echo -e "${On_IRed}${tableName} already exists${NC}" && tableMenu
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
					echo -e "${Yellow}choose type of column ${columnName}${NC}"
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
							echo -e "${On_IRed}Invalid choice! Please choose from the options available${NC}"
							;;
						esac
					done
					;;
				*)
					echo -e "${On_IRed}Invalid name${NC}"
					createTable
					break
					;;
				esac

				#asking for pk
				if [ -z ${primaryKey} ]; then
					echo -e "${Yellow}Do you want this column to be the pk?${NC}"
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
							echo -e "${On_IRed}Invalid choice! Please choose from the options available${NC}"
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
				clear
				echo -e "${On_IGreen}Table Created Successfully${NC}"
				tableMenu
			else
				clear
				echo -e "${On_IRed}Error Creating Table $tableName${NC}"
				tableMenu
			fi
			;;
		*)
			clear
			echo -e "${On_IRed}Invalid input, please enter a numeric input\n${NC}"
			createTable
			;;
		esac
		;;
	*)
		clear
		echo -e "${On_IRed}Invalid Naming Convention table name should not start with a number or a specail character\n${NC}"
		createTable
		;;
	esac
}


function insert() {
	read -e -p "Enter table name: " tName
	tName=$(echo ${tName// /_})
	case $tName in
	+([a-zA-Z]*))
		test ! -f ${tName} && echo -e "${On_IRed}${tName} does not exist${NC}" && tableMenu
		;;
	*)
		clear
		echo -e "${On_IRed}Invalid input!${NC}"
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
				echo -e "${On_IRed}Invalid input, int data type must be numbers!${NC}"
				read -e -p "Enter the data in ${columnName} (${columnType}): " data
			done
		fi

		if [ "${columnKey}" = "PK" ]; then

			until ! [[ ($data =~ ^[$(awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' ${tName})]$ || -z ${data}) ]]; do
				echo -e "${On_IRed}invalid input for Primary Key , Primary key should be unique and not null!\n${NC}"
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
		clear
		echo -e "${On_IGreen}Data Inserted Successfully\n${NC}"
	else
		clear
		echo -e "${On_IRed}Error Inserting Data into Table ${tName}\n${NC}"
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
						echo -e "${Yellow}***Empty Set***${NC}"
					fi
					echo "Press Eneter to return back to Select Menu"
					read cont
					selectfromTable
				;;
				"Select Entire Column")
					typeset -i listofCol

					echo -e "The existing Columns are: \n======================="
					awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
					listofCol=`(awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l)`
					
					echo "Enter the No. of the Column you want to Select from: "
					echo "Note: range from 1:99"
					read -n 2 selectedCol
					case ${selectedCol} in
						+([1-9]|[1-9][0-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								header=`sed -n '1p' ./${tableName} | awk -F: -v grab=$selectedCol '{print $grab}'`
								result=`awk -F: -v grab=$selectedCol '{if (NR>1) print $grab}' ./${tableName}`
								if [[ -z $result ]]
									then
										echo $header
										echo -e "${Yellow}***Empty Set***${NC}"
									else
										echo $header
										awk -F: -v grab=$selectedCol '{if (NR>1) print $grab}' ./${tableName}
									fi
								echo "Press Eneter to return back to Select Menu"
								read cont
								selectfromTable
							else
								echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Select Menu"
								sleep 3
								selectfromTable
							fi
						;;
						*)
							echo -e "${On_IRed}Invalid input!${NC}\nReturning back to Select Menu"
							sleep 3
							selectfromTable
						;;
					esac
				;;
				"Select Entire Row")
					typeset -i listofCol

					echo -e "The existing Columns are: \n======================="
					awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
					listofCol=`(awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l)`
					
					echo "Enter the No. of the Column you want to Select from: "
					echo "Note: range from 1:99"
					read -n 2 selectedCol
					case ${selectedCol} in
						+([1-9]|[1-9][0-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								selectedCol=$selectedCol+1
								sed -n ${selectedCol}p ./.${tableName}_metaData | grep int > /dev/null
								let ifInt=$?
								if [[ ifInt -eq 0 ]]
								then
									echo -e "${On_IGreen}You choose an Integer type Column.\n${NC}Please enter the No. you want to search for"
									read requiredData
									index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1`
									if [ -z $index ]
									then
										echo -e "${Yellow}***Empty Set***${NC}"
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
										echo -e "${On_IGreen}You choose a String type Column.\n${NC}Please enter the word you want to search for"
										read requiredData
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -iwn $requiredData | cut -d: -f1`
									
										if [ -z $index ]
										then
											echo -e "${Yellow}***Empty Set***${NC}"
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
								echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Select Menu"
								sleep 3
								selectfromTable
							fi
						;;
						*)
							echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Select Menu"
							sleep 3
							selectfromTable
						;;
					esac
				;;
				"Select Certain Value")
					typeset -i listofCol

					echo -e "The existing Columns are: \n======================="
					awk -F: '{if (NR>1) print NR-1,$1}' ./.${tableName}_metaData
					listofCol=`(awk -F: '{if (NR>1) print $0}' ./.${tableName}_metaData | wc -l)`
					
					echo "Enter the No. of the Column you want to Select from: "
					echo "Note: range from 1:99"
					read -n 2 selectedCol
					case $selectedCol in
						+([1-9]|[1-9][0-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								selectedCol=$selectedCol+1
								sed -n ${selectedCol}p ./.${tableName}_metaData | grep int > /dev/null
								let ifInt=$?
								selectedCol=$selectedCol-1
								if [[ ifInt -eq 0 ]]
								then
									echo -e "${On_IGreen}You choose an Integer type Column.\n${NC}Please enter the No. you want to search for"
									read requiredData
									while [[ -z $requiredData ]]
									do
										echo -e "${On_IRed}Invalid Entry! Enter valid data: ${NC}"
										read requiredData ;
									done
									result=`awk -F: -v grab=$selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData`
									resultLine=`echo $result | awk -F: -v RS=' ' '{print $1}'` 
									if [ -z $result ]
									then
										echo -e "${Yellow}***Empty Set***${NC}"
									else
										echo "========================================="
										echo -e "  ${On_IGreen}value $requiredData exists in line${NC}"
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
										echo -e "${On_IGreen}You choose a String type Column.\n${NC}Please enter the word you want to search for"
										read requiredData
										result=`awk -F: -v grab=$selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData`
										resultLine=`echo $result | awk -F: -v RS=' ' '{print $1}'` 
										if [ -z "$result" ]
										then
											echo -e "${Yellow}***Empty Set***${NC}"
										else
											echo "========================================="
											echo -e "  ${On_IGreen}value $requiredData exists in line${NC}"
											echo -e "\t"$resultLine
											echo "========================================="
										fi
									fi	

								fi
								echo "Press Eneter to return back to Select Menu"
								read cont
								selectfromTable
							else
								echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Select Menu"
								sleep 3
								selectfromTable
							fi
						;;
						*)
							echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Select Menu"
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
		
		echo -e "${On_IRed}Invalid table name!${NC}\nReturning back to Select Menu"
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
						header=`sed -n '1p' ./${tableName}`
						echo $header>./${tableName}
						let delDone=$?
						if [[ delDone -eq 0 ]]
						then
							echo -e "${On_IGreen}Data Deleted Successfully${NC}"
						else
							echo -e "${On_IRed}Error: Delete Aborted!${NC}"
						fi
					else
						echo -e "${Yellow}***Empty Set***${NC}"
					fi
					echo "Press Eneter to return back to Delete Menu"
					read cont
					deleteTable
				;;
				"Delete Entire Row")
					typeset -i listofCol
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
									echo -e "${On_IGreen}You choose an Integer type Column.\n${NC}Please enter the No. you want to Delete"
									read requiredData
									case ${requiredData} in
									+([0-9]))
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1`
										indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l`
										if [[ -z $index ]]
										then
											echo -e "${Yellow}***Empty Set***${NC}"
										else
											let decrement=0
											echo -e "${On_IGreen}Value exists in "$indexlist" records.${NC}"
											for (( i=1; i<=$indexlist; i++))
											do
												line=`echo $index | cut -d' ' -f$i `
												echo $line
												if [[ $i -gt 1 ]]
												then
													for ((j=1;j<=decrement;j++))
													do
														((line--))
													done
												fi
												sed -in ${line}d ./${tableName}
												delDone=$?
												if [[ delDone -eq 0 ]]
												then
													echo -e "${On_IGreen}Row Deleted Successfully${NC}"
													(( decrement++ ))
												else
													echo -e "${On_IRed}Error: Delete Aborted!${NC}"
												fi
											done
										fi
									;;
									*)
									echo -e "${On_IRed}Invalid Entry!${NC}\nReturning back to Delete Menu"
									sleep 3
									deleteTable
									;;
									esac
								else
									(( selectedCol++ ))
									sed -n ${selectedCol}p ./.${tableName}_metaData | grep string > /dev/null
									let ifString=$?
									(( selectedCol-- ))
									if [[ ifString -eq 0 ]]
									then
										echo -e "${On_IGreen}You choose a String type Column.\n${NC}Please enter the word you want to Delete"
										read requiredData
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1`
										indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l`
										if [ -z $index ]
										then
											echo -e "${Yellow}***Empty Set***${NC}"
										else
											let decrement=0
											echo -e "${On_IGreen}Value exists in "$indexlist" records.${NC}"
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
													echo -e "${On_IGreen}Row Deleted Successfully${NC}"
													(( decrement++ ))
												else
													echo -e "${On_IRed}Error: Delete Aborted!${NC}"
												fi
											done
										fi
									fi	

								fi

								echo "Press Eneter to return back to Delete Menu"
								read cont
								deleteTable
							else
								echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Delete Menu"
								sleep 3
								deleteTable
							fi
						;;
						*)
							echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Delete Menu"
							sleep 3
							deleteTable
						;;
					esac
				;;

				"Delete Certain Value")
					typeset -i listofCol
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
									echo -e "${On_IGreen}You choose an Integer type Column.\n${NC}Please enter the No. you want to Delete"
									read requiredData
									case ${requiredData} in
									+([0-9]))
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1`
										indexlist=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l`
										if [ -z "$index" ]
										then
											echo -e "${Yellow}***Empty Set***${NC}"
										else
											echo -e "${On_IGreen}Value exists in "$indexlist" records.${NC}\n======================="
											echo $index
											read -p "Enter the No. of the line you want to delete from it: " line
											sed -in "$line s/$requiredData/$blank/" ./${tableName}
											delDone=$?
											if [[ delDone -eq 0 ]]
											then
												echo -e "${On_IGreen}Value Deleted Successfully${NC}"
 											else
												echo -e "${On_IRed}Error: Delete Aborted!${NC}"
											fi
										fi
									;;
									*)
										echo -e "${On_IRed}Invalid Entry!${NC}\nReturning back to Delete Menu"
										sleep 3
										deleteTable
									;;
									esac
								else
									(( selectedCol++ ))
									sed -n ${selectedCol}p ./.${tableName}_metaData | grep string > /dev/null
									let ifString=$?
									(( selectedCol-- ))
									if [[ ifString -eq 0 ]]
									then
										echo -e "${On_IGreen}You choose a String type Column.\n${NC}Please enter the word you want to Delete"
										read requiredData
										index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | cut -d: -f1`
										indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -in $requiredData | wc -l`
										if [ -z "$index" ]
										then
											echo -e "${Yellow}***Empty Set***${NC}"
										else
											echo -e "${On_IGreen}Value exists in "$indexlist" records.${NC}\n======================="
											echo $index
											read -p "Enter the No. of the line you want to delete from it: " line
											sed -in "$line s/$requiredData/$blank/" ./${tableName}
											delDone=$?
											if [[ delDone -eq 0 ]]
											then
												echo -e "${On_IGreen}Value Deleted Successfully${NC}"
 											else
												echo -e "${On_IRed}Error: Delete Aborted!${NC}"
											fi
										fi
									fi	

								fi

								echo "Press Eneter to return back to Delete Menu"
								read cont
								deleteTable
							else
								echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Delete Menu"
								sleep 3
								deleteTable
							fi
						;;
						*)
							echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Delete Menu"
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
		
		echo -e "${On_IRed}Invalid table name!${NC}\nReturning back to Delete Menu"
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
							echo -e "${On_IGreen}You choose an Integer type Column.{NC}"
							if [[ ifPK -eq 0 ]]
							then 
								echo "This is the PK of the Table"
								read -p "Enter the data you want to Update: "  requiredData
								index=`awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | cut -d: -f1`
								indexlist=`awk -F' ' -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $requiredData | wc -l`
								if [ -z "$index" ]
								then
									echo -e "${Yellow}***Empty Set***${NC}"
									sleep 3
									updateTable
								else
									echo -e "${On_IGreen}Value exists in "$indexlist" records.${NC}\n======================="
									echo $index
									read -p "Enter the No. of the line you want to Update from it: " line
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
												echo -e "${On_IRed}Error: PK Repetition!${NC}"
											else
												sed -in "$line s/$requiredData/$newData/" ./${tableName}
												let upDone=$?
												if [[ upDone -eq 0 ]]
												then
													echo -e "${On_IGreen}No. Updated Successfully${NC}"
													((trueUpdate++))
												else
													echo -e "${On_IRed}Error: Update Aborted!${NC}"
												fi

											fi
										;;
										*)
										echo -e "${On_IRed}Invalid Entry!${NC}"
										;;
										esac
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
									echo -e "${Yellow}***Empty Set***${NC}"
									sleep 3
									updateTable
								else
									echo -e "${On_IGreen}Value exists in "$indexlist" records.${NC}\n======================="
									echo $index
									read -p "Enter the No. of the line you want to Update from it: " line
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
												echo -e "${On_IGreen}No. Updated Successfully${NC}"
												((trueUpdate++))
											else
												echo -e "${On_IRed}Error: Update Aborted!${NC}"
											fi
										;;
										*)
										echo -e "${On_IRed}Invalid Entry!${NC}"
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
									echo -e "${Yellow}***Empty Set***${NC}"
									sleep 3
									updateTable
								else
									echo -e "${On_IGreen}Value exists in "$indexlist" records.${NC}\n======================="
									echo $index
									read -p "Enter the No. of the line you want to Update from it: " line
									read -p "Enter the new No.: " newData
									awk -F: -v grab=selectedCol '{print $grab}' ./${tableName} | grep -wn $newData
									let ifFound=$?
									let trueUpdate=0
									while [ trueUpdate -eq 0 ]
									do
										if [[ ifFound -eq 0 ]]
										then
											echo -e "${On_IRed}Error: PK Repetition!${NC}"
										else
											sed -in "$line s/$requiredData/$newData/" ./${tableName}
											let upDone=$?
											if [[ upDone -eq 0 ]]
											then
												echo -e "${On_IGreen}No. Updated Successfully${NC}"
												((trueUpdate++))
											else
												echo -e "${On_IRed}Error: Update Aborted!${NC}"
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
									echo -e "${Yellow}***Empty Set***${NC}"
									sleep 3
									updateTable
								else
									echo -e "${On_IGreen}Value exists in "$indexlist" records.${NC}\n======================="
									echo $index
									read -p "Enter the No. of the line you want to Update from it: " line

									let trueUpdate=0
									while [ trueUpdate -eq 0 ]
									do
										sed -in "$line s/$requiredData/$newData/" ./${tableName}
										let upDone=$?
										if [[ upDone -eq 0 ]]
										then
											echo -e "${On_IGreen}No. Updated Successfully${NC}"
											((trueUpdate++))
										else
											echo -e "${On_IRed}Error: Update Aborted!${NC}"
										fi

									done
								fi
							fi
						fi

					else
						echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Update Menu"
						sleep 3
						updateTable
					fi
				;;
				*)
					echo -e "${On_IRed}Invalid Column No.!${NC}\nReturning back to Update Menu"
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
		
		echo -e "${On_IRed}Invalid table name!${NC}\nReturning back to Update Menu"
		sleep 3
		updateTable
	fi
}


tableMenu
