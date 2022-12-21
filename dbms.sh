#!/bin/bash

shopt -s extglob
export LC_COLLATE=C
Red='\033[0;31m'
Green='\033[0;32m'
NC='\033[0m'
Yellow='\033[0;33m'
On_IGreen='\033[0;102m'
On_IRed='\033[0;101m'

mkdir dbms

clear

function mainMenu() {
	select choice in "Create Database" "List Databases" "Connect To Databases" "Rename databases" "Delete Database" "Exit"; do
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
			echo -e "${On_IRed}Please choose from the options available!\n${NC}"
			mainMenu
			;;
		esac
	done
}

function CreateDB() {
	read -e -p "Please Enter database name: " dbName
	dbName=$(echo ${dbName// /_})
	if [[ ${dbName} =~ ^['*'] ]]; then
		echo "${On_IRed}invalid input!${NC}"
	fi

	case $dbName in
<<<<<<< HEAD
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
=======
	+([a-zA-Z]*))
		mkdir ./dbms/"${dbName}" 2>>/dev/null
		if [ $? -eq 0 ]; then
			echo -e "${On_IGreen}The database is created\n${NC}"
		else
			echo -e "${On_IRed}The database already exists\n${NC}"
		fi
		;;
	*)
		clear
		echo -e "${On_IRed}Invalid,Database name should not start with a number or a specail character\n${NC}"
>>>>>>> 6e850cfdea3dbc48f0f8b4d7de3b1091f77a7cad
		;;
	esac
	
	mainMenu
}

function connectToDB() {
	pwd=$PWD
	read -e -p "Please Enter database name: " dbName
	dbName=$(echo ${dbName// /_})
	case $dbName in
	+([a-zA-Z]*))
		cd ./dbms/"${dbName}" 2>>/dev/null
		if [ $? -eq 0 ]; then
			echo -e "${On_IGreen}The Database is selected Successfully\n${NC}"
			source ${pwd}/.table.sh
			clear
		else
			echo -e "${On_IRed}The database was not found\n${NC}"
			mainMenu
		fi
		;;
	*)
		clear
		echo -e "${On_IRed}Invalid name!${NC}"
		mainMenu
		;;
	esac
}

function listDatabases() {
	clear
	echo -e "List of the databases exist:\n"
	ls -F ./dbms | grep / 2>>/dev/null
	echo -e "\n"
	mainMenu
}

function renameDB() {
	read -e -p "Enter current database name: " oldDB
	read -e -p "Enter the new database name: " newDB
	newDB=$(echo ${newDB// /_})
	oldDB=$(echo ${oldDB// /_})
	case $newDB in
	+([a-zA-Z]*))
		mv ./dbms/"${oldDB}" ./dbms/"${newDB}" 2>>/dev/null
		if [ $? -eq 0 ]; then
			echo -e "${On_IGreen}Database renamed\n${NC}"
		else
			echo -e "${On_IRed}Database renaming failed\n${NC}"
		fi
		;;
	*)
		clear
		echo -e "${On_IRed}Invalid,database name should not start with a number or a specail character\n${NC}"
		;;
	esac
	mainMenu
}

function deleteDB() {
	read -e -p "Enter database name: " name
	name=$(echo ${name// /_})
	clear
	case $name in
	+([a-zA-Z]*))
		echo -e "${Yellow}Are you sure you want to delete database ${name}${NC}"
		select ch in "Yes" "No"; do
			case $ch in
			"Yes")
				rm -r ./dbms/"${name}" 2>>/dev/null
				if [ $? -eq 0 ]; then
					echo -e "${On_IGreen}Database is deleted\n${NC}"
				else
					echo -e "${On_IRed}Database does not exist\n${NC}"
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

	mainMenu
}

mainMenu
