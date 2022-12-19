#!/bin/bash

shopt -s extglob
export LC_COLLATE=C

mkdir dbms

clear



function mainMenu(){
select choice in "Create Database" "List Databases" "Connect To Databases" "Rename databases" "Delete Database" "Exit"
do
case $choice in
"Create Database")
	CreateDB
;;
"List Databases")
	listDatabases
;; 
"Connect To Databases")
	connectToDB
;;
"Rename databases")
	renameDB
;;
"Delete Database")
	deleteDB
;;
"Exit")
 exit
;;
*)
echo -e "Please choose from the options available!\n"
mainMenu
esac
done
}

function CreateDB(){
	read -p "Please Enter database name: " dbName
	case $dbName in
	+([a-zA-Z]*))
	mkdir ./dbms/"${dbName}" 2>> error.text
	if [ $? -eq 0 ]
	then
		echo -e "The database is created\n"
	else
		echo -e "The database is already exist\n" 
	fi
	;;
	*)
	clear
	echo -e "Invalid Naming Conventions database name should not start with a number or a specail character\n"
	;;
	esac
	mainMenu
}

function connectToDB(){
	pwd=$PWD
	read -p "Please Enter database name: " dbName
	cd ./dbms/"${dbName}" 2>> error.text
	if [ $? -eq 0 ]
	then
	echo -e "The Database is selected Successfully\n"
	source ${pwd}/table.sh
	clear
	else
	echo -e "The database was not found\n" 
	mainMenu
	fi
}

function listDatabases(){
	clear
	echo -e "List of the databases exist:\n"
	ls -F ./dbms | grep /
	echo -e "\n"
	mainMenu
}

function renameDB(){
	read -p "Enter database name: " oldDB
	read -p "Enter the new database name: " newDB
	mv ./dbms/"${oldDB}" ./dbms/"${newDB}" 2>> error.text
	
	if [ $? -eq 0 ]
	then
	echo -e "Database renamed\n"
	else
	echo -e "Database renaming failed\n"
	fi
	mainMenu
}

function deleteDB(){
	read -p "Enter database name: " name
	rm -r ./dbms/"${name}" 2>> error.text

	if [ $? -eq 0 ]
	then
	echo -e "Database is deleted\n"
	else
	echo -e "Database is not exist\n"
	fi
	mainMenu	
}

mainMenu






