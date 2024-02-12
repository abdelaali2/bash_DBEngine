#!/bin/bash

# TODO: Build Terminal User Interface (TUI) using dialog command

function initialization() {
	shopt -s extglob
	export LC_COLLATE=C

	# shellcheck disable=SC1091
	source .constants.sh
	# shellcheck disable=SC1091
	source .utilities.sh

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
			CreateDB
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

function CreateDB() {
	dbName=$(readInput "$PROMPT_READ_DB_NAME")

	if textValidator "$dbName"; then
		dbPath="$RECORDS_DIRECTORY/$dbName"

		if [ -d "$dbPath" ]; then
			echo -e "${STYLE_ON_IRED}$PROMPT_DB_DUPLICATE_ERROR${STYLE_NC}"
			mainMenu
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
	echo -e "$PROMPT_CURRENT_DBS"
	for db in "$RECORDS_DIRECTORY"/*/; do
		if [ -d "$db" ]; then
			echo -e "=> $(basename -a "$db")\n"
		fi
	done
	if [[ ! $1 ]]; then
		mainMenu
	fi
}

function connectToDB() {
	listDBs "skipMainMenu"
	dbName=$(readInput "$PROMPT_READ_DB_NAME")

	if textValidator "$dbName"; then
		dbPath="$RECORDS_DIRECTORY/$dbName"

		if [[ -d "$dbPath" ]]; then
			clear
			# shellcheck disable=SC1091
			# shellcheck disable=SC1090
			source "$DB_ENGINE" "$dbPath"
		else
			echo -e "${STYLE_ON_IRED}$PROMPT_DB_NOT_FOUND${STYLE_NC}"
		fi
	else
		clear
		echo -e "${STYLE_ON_IRED}$PROMPT_INVALID_INPUT${STYLE_NC}"
	fi
	mainMenu
}

function renameDB() {
	listDBs "skipMainMenu"
	oldDB=$(readInput "$PROMPT_READ_DB_NAME")

	if textValidator "$oldDB"; then
		newDB=$(readInput "$PROMPT_READ_NEW_DB_NAME")
		if textValidator "$newDB"; then
			if mv "$RECORDS_DIRECTORY/$oldDB" "$RECORDS_DIRECTORY/$newDB"; then
				echo -e "${STYLE_ON_IGREEN}$PROMPT_DB_RENAMING_DONE${STYLE_NC}"
			else
				echo -e "${STYLE_ON_IRED}$PROMPT_DB_RENAMING_ERROR${STYLE_NC}"
			fi
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
	listDBs "skipMainMenu"
	dbName=$(readInput "$PROMPT_READ_DB_NAME")

	if textValidator "$dbName"; then
		dbPath="$RECORDS_DIRECTORY/$dbName"

		confirmChoice "$dbName $PROMPT_DELETION_CONFIRM"
		choice=$?

		case "${choice}" in
		0)
			if rm -r "$dbPath" 2>>/dev/null; then
				echo -e "${STYLE_ON_IGREEN}$PROMPT_DB_DELETION_DONE${STYLE_NC}"
			else
				echo -e "${STYLE_ON_IRED}$PROMPT_DB_NOT_FOUND${STYLE_NC}"
			fi
			;;
		1)
			echo -e "${STYLE_YELLOW}$PROMPT_DB_DELETION_CANCELLED${STYLE_NC}"
			;;
		*)
			echo -e "${STYLE_ON_IRED}$PROMPT_DB_DELETION_ERROR${STYLE_NC}"
			;;
		esac

	else
		clear
		echo -e "${STYLE_ON_IRED}$PROMPT_INVALID_INPUT${STYLE_NC}"
	fi

	mainMenu
}

mainMenu
