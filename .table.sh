#!/bin/bash


function tableMenu(){
select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Exit"
do
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
	renameDB
;;
"Select From Table")
	selectfromTable
;;
"Delete From Table")
	deleteDB
;;
"Update Table")
;;
"Exit")
exit
;;
*)
echo -e "Please choose from the options available!\n"
tableMenu
esac
done
}

function listTables(){
    clear
    ls .
    echo -e "\n"
	tableMenu
}

function dropTable(){
   read -p "Enter table name: " tableName
   rm "${tableName}" 2>> ../../error.text
   if [ $? -eq 0 ]
   then
   echo -e "Table is dropped\n"
   rm "${tableName}_metaData" 2>> ../../error.text
   else
   echo -e "Error dropping the table\n"
   fi
   tableMenu
}

function createTable(){
	#asking for table name
	read -p "Please Enter table name: " tableName
	tableName=`echo ${tableName// /_}`

	if [ -f "${tableName}" ]
	then
		echo "Table is already exist"
		tableMenu
	fi

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
			while [ ${counter} -le ${colNumber} ]
			do
				#asking for the name of the column
				read -p "Please enter the name of column no.${counter}: " columnName
				columnName=`echo ${columnName// /_}`
				case "${columnName}" in
				+([a-zA-Z]*))
					#asking for the type of the column
					echo "choose type of column ${columnName}"
					select ch in "integer" "string"
					do
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
				if [ -z ${primaryKey} ]
					then
					echo -e "Do you want this column to be the pk?"
					select ch in "Yes" "No"
					do
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

				if [ $counter -eq $colNumber ] 
					then
					tableHeader=$tableHeader$columnName
					else
					tableHeader=$tableHeader$columnName$sep
				fi

				((counter++))

			done #end of while

			touch "${tableName}_metaData"
			touch "${tableName}"
			echo -e $metaData  >> "${tableName}_metaData"
			echo -e $tableHeader >> ${tableName}
			if [ $? -eq 0 ]
				then
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


















































































































function selectfromTable() {

	clear
	read -p "Please Enter table name: " tableName
	tableName=`echo ${tableName// /_}`

	if [ -f "${tableName}" ]
	then
		select input in "Select all" "Select entire Column" "Select entire Row" "Select Certain Value" "Return"
		do
			case $input in
			
				"Select all")
					typeset -i chkData
					chkData=`cat $PWD/"${tableName}" | wc -l`
					if [[ chkData -gt 1 ]]
					then
						cat $PWD/"${tableName}" | more
					else
						echo "Empty Set"
					fi
					echo "Press Eneter to return back to Select Menu"
					read cont
					selectfromTable
				;;
				"Select entire Column")
					typeset -i listofCol
					typeset -i selectedCol

					echo -e "The existing Columns are: \n"
					awk -F: '{if (NR>1) print NR-1,$1}' ${tableName}_metaData
					listofCol=`(awk -F: '{if (NR>1) print $0}' ${tableName}_metaData | wc -l)`
					
					read -p "Enter the No. of the Column you want to Select: " selectedCol
					case ${selectedCol} in
						+([1-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								awk -F: -v grab=$selectedCol '{print $grab}' ${tableName}
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
				"Select entire Row")
					typeset -i listofCol
					typeset -i selectedCol

					echo -e "The existing Columns are: \n"
					awk -F: '{if (NR>1) print NR-1,$1}' ${tableName}_metaData
					listofCol=`(awk -F: '{if (NR>1) print $0}' ${tableName}_metaData | wc -l)`
					
					read -p "Enter the No. of the Column you want to Select from: " selectedCol
					case ${selectedCol} in
						+([1-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								selectedCol=$selectedCol+1
								sed -n ${selectedCol}p ./${tableName}_metaData | grep int > /dev/null
								let ifInt=$?
								if [[ ifInt -eq 0 ]]
								then
									echo -e "You choose an Integer type Column.\nPlease enter the No. you want to search for"
									read requiredData
									index=`awk -F: -v grab=selectedCol '{print $grab}' ${tableName} | grep -wn $requiredData | cut -d: -f1`
									if [ -z $index ]
									then
										echo "***Empty Set***"
									else
										for i in $index
										do
											sed -n ${i}p ${tableName}
										done
									fi
								else
									sed -n ${selectedCol}p ${tableName}_metaData | grep string > /dev/null
									let ifString=$?
									if [[ ifString -eq 0 ]]
									then
										echo -e "You choose a String type Column.\nPlease enter the word you want to search for"
										read requiredData
										index=`awk -F: -v grab=selectedCol '{print $grab}' ${tableName} | grep -iwn $requiredData | cut -d: -f1`
									
										if [ -z $index ]
										then
											echo "***Empty Set***"
										else
											for i in $index
											do
												sed -n ${i}p ${tableName}
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

					echo -e "The existing Columns are: \n"
					awk -F: '{if (NR>1) print NR-1,$1}' ${tableName}_metaData
					listofCol=`(awk -F: '{if (NR>1) print $0}' ${tableName}_metaData | wc -l)`
					
					read -p "Enter the No. of the Column you want to Select from: " selectedCol
					case ${selectedCol} in
						+([1-9]))
							if [[ $selectedCol -le $listofCol ]]
							then
								selectedCol=$selectedCol+1
								sed -n ${selectedCol}p ./${tableName}_metaData | grep int > /dev/null
								let ifInt=$?
								selectedCol=$selectedCol-1
								if [[ ifInt -eq 0 ]]
								then
									echo -e "You choose an Integer type Column.\nPlease enter the No. you want to search for"
									read requiredData
									result=`awk -F: -v grab=$selectedCol '{print $grab}' ${tableName} | grep -in $requiredData`
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
									sed -n ${selectedCol}p ${tableName}_metaData | grep string > /dev/null
									let ifString=$?
									selectedCol=$selectedCol-1
									if [[ ifString -eq 0 ]]
									then
										echo -e "You choose a String type Column.\nPlease enter the word you want to search for"
										read requiredData
										result=`awk -F: -v grab=$selectedCol '{print $grab}' ${tableName} | grep -in $requiredData`
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
	tableMenu


}




tableMenu
