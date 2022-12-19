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
	deleteDB
;;
"Delete From Table")
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
   echo -e "Table is dropped"
   else
   echo -e "Error dropping the table"
   fi
   tableMenu
}

function createTable(){
	#asking for table name
	read -p "Please Enter table name: " tableName

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
				columnName=`${columnName// /_}`
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





function selectfromTable(){
	clear
	select choice in "Select all" "Select entire column" "Select from column" "Exit"

	case $choice in
	"Select all")
	cat "${tableName}"
	;;
	"Select entire column")
	
	;;
	"Select from column")
	;;
	"Exit")
	;;

	#read -p "Enter table name: " tableName
	#rm "${tableName}" 2>> ../../error.text
	#if [ $? -eq 0 ]
	#then
	#echo -e "Table is dropped"
	#else
	#echo -e "Error dropping the table"
	#fi

	tableMenu
}
tableMenu
