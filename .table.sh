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

tableMenu
