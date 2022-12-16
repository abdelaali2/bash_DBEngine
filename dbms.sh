#!/bin/bash

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
	echo "d"
;; 
"Connect To Databases")
	connectToDB
;;
"Rename databases")
	echo "a"
;;
"Delete Database")
	echo "g"
;;
"Exit")
 exit
;;
*)
echo "not found"
esac
done
}

function CreateDB(){
	read -p "Please Enter database name: " dbName
	mkdir ./dbms/${dbName} 2>> error.text
	if [ $? -eq 0 ]
	then
	echo "The database is created"
	else
	echo "The database is already exist" 
	fi
}

function connectToDB(){
	read -p "Please Enter database name: " dbName
	cd ./dbms/${dbName} 2>> error.text
	if [ $? -eq 0 ]
	then
	echo "The Database is selected Successfully"
	#tablesMenu
	else
	echo -e "The database was not found\n" 
	mainMenu
	fi
}




mainMenu




