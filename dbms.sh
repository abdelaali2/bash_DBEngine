#!/bin/bash

function initialization() {
	shopt -s extglob
	export LC_COLLATE=C

	# shellcheck disable=SC1091
	source constants.sh

	if [ ! -d "$RECORDS_DIRECTORY" ]; then
		mkdir "$RECORDS_DIRECTORY"
		clear
		echo -e "$PROMPT_WELCOME"
	else
		clear
		echo -e "$PROMPT_WELCOME_BACK"
	fi
}

initialization

function mainMenu() {
	select choice in "$CREATE_DB" "$LIST_DB" "$CONNECT_TO_DB" "$RENAME_DB" "$DELETE_DB" "$EXIT"; do
		case $choice in
		"$CREATE_DB")
			CreateDB || return
			;;
		"$LIST_DB")
			listDBs
			;;
		"$CONNECT_TO_DB")
			connectToDB
			;;
		"$RENAME_DB")
			renameDB
			;;
		"$DELETE_DB")
			deleteDB
			;;
		"$EXIT")
			exit
			;;
		*)
			echo -e "${STYLE_ON_IRED}$PROMPT_INVALID_INPUT${STYLE_NC}"
			mainMenu
			;;
		esac
	done
}

function readDBName() {
	read -re -p "$PROMPT_READ_DB_NAME" input
	echo "${input// /_}"
}

function validator() {
	local input=$1
	if [[ $input == +([a-zA-Z]*) ]]; then
		echo true
	else
		echo false
	fi
}

function CreateDB() {
	dbName=$(readDBName)

	if validator "$dbName"; then
		dbPath="$RECORDS_DIRECTORY/$dbName"

		if [ -d "$dbPath" ]; then
			echo -e "${STYLE_ON_IRED}$PROMPT_DB_DUPLICATE_ERROR${STYLE_NC}"
			return 1
		fi

		mkdir -p "$dbPath" 2>>/dev/null
		echo -e "${STYLE_ON_IGREEN}$PROMPT_DB_CREATION_DONE${STYLE_NC}"
	else
		clear
		echo -e "${STYLE_ON_IRED}$PROMPT_INVALID_INPUT${STYLE_NC}"
	fi

	mainMenu
}

function listDBs() {
	clear
	for db in "$RECORDS_DIRECTORY"/*/; do
		if [ -d "$db" ]; then
			echo -e "$(basename -a "$db")\n"
		fi
	done

	mainMenu
}

function connectToDB() {
	dbName=$(readDBName)
	dbPath="$RECORDS_DIRECTORY/$dbName"

	if validator "$dbName"; then
		cd "$RECORDS_DIRECTORY/$dbName" 2>>/dev/null || {
			echo -e "${STYLE_ON_IRED}$PROMPT_DB_NOT_FOUND${STYLE_NC}"
			mainMenu
		}
		clear
		# shellcheck disable=SC1091
		# shellcheck disable=SC1090
		source "$DB_ENGINE"
	else
		clear
		echo -e "${STYLE_ON_IRED}$PROMPT_INVALID_INPUT${STYLE_NC}"
		mainMenu
	fi
}

function renameDB() {
	oldDB=$(readDBName)

	if validator "$oldDB"; then
		newDB=$(readDBName)
		if [[ $(validator "$newDB") ]]; then
			mv "$RECORDS_DIRECTORY/$oldDB" "$RECORDS_DIRECTORY/$newDB" || {
				echo -e "${STYLE_ON_IRED}$PROMPT_DB_RENAME_ERROR${STYLE_NC}"
				return
			}
			echo -e "${STYLE_ON_IGREEN}$PROMPT_DB_RENAME_DONE${STYLE_NC}"
		else
			echo -e "${STYLE_ON_IRED}$PROMPT_INAVLID_DB_NAME${STYLE_NC}"
		fi

	else
		clear
		echo -e "${STYLE_ON_IRED}$PROMPT_INAVLID_DB_NAME${STYLE_NC}"
	fi
	mainMenu
}

function deleteDB() {
	dbName=$(readDBName)
	clear
	case $name in
	+([a-zA-Z]*))
		echo -e "${STYLE_YELLOW}Are you sure you want to delete database ${name}${STYLE_NC}"
		select ch in "Yes" "No"; do
			case $ch in
			"Yes")
				rm -r ./dbms/"${name}" 2>>/dev/null
				if [ $? -eq 0 ]; then
					echo -e "${STYLE_ON_IGREEN}Database is deleted\n${STYLE_NC}"
				else
					echo -e "${STYLE_ON_IRED}Database does not exist\n${STYLE_NC}"
				fi
				break
				;;
			"No")
				break
				;;
			*)
				echo -e "${STYLE_ON_IRED}Please choose from the options avaliable!${STYLE_NC}"
				;;
			esac
		done
		;;
	*)
		clear
		echo -e "${STYLE_ON_IRED}Invalid input!\n${NC}"
		;;
	esac

	mainMenu
}

mainMenu
