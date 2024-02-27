#!/bin/bash

# TODO: Build Terminal User Interface (TUI) using dialog command

function initialization() {
	shopt -s extglob
	export LC_COLLATE=C

	# shellcheck disable=SC1091
	source .constants.sh
	# shellcheck disable=SC1091
	source .utilities.sh
	if [ ! -f "$VALIDATION_STATE" ]; then
		touch "$VALIDATION_STATE"
	fi

	if [ ! -d "$RECORDS_DIRECTORY" ]; then
		mkdir "$RECORDS_DIRECTORY"
		clear
		printGreeting "$PROMPT_WELCOME"
	else
		clear
		printGreeting "$PROMPT_WELCOME_BACK"
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
			printError "$PROMPT_INVALID_INPUT"
			mainMenu
			;;
		esac
	done
}

function CreateDB() {
	readValidName "$PROMPT_READ_DB_NAME"
	dbName=$(retrieveValidatedInput)

	dbPath="$RECORDS_DIRECTORY/$dbName"

	if [ -d "$dbPath" ]; then
		printError "$PROMPT_DB_DUPLICATE_ERROR"
		mainMenu
	fi

	if mkdir -p "$dbPath" 2>>/dev/null; then
		printSuccess "$PROMPT_DB_CREATION_DONE"
	else
		printError "$PROMPT_DB_CREATION_FAILED"
	fi

	mainMenu
}

function listDBs() {
	clear
	echo -e "$PROMPT_CURRENT_DBS"
	for db in "$RECORDS_DIRECTORY"/*/; do
		if [ -d "$db" ]; then
			printListItem "$(basename -a "$db")"
		fi
	done
	if [[ ! $1 ]]; then
		mainMenu
	fi
}

function connectToDB() {
	# TODO: check if there is no db created already.
	listDBs "skipMainMenu"
	readValidName "$PROMPT_READ_DB_NAME"
	dbName=$(retrieveValidatedInput)

	dbPath="$RECORDS_DIRECTORY/$dbName"

	if [[ -d "$dbPath" ]]; then
		clear
		# shellcheck disable=SC1091
		# shellcheck disable=SC1090
		source "$DB_ENGINE" "$dbPath"
	else
		printError "$PROMPT_DB_NOT_FOUND_ERROR"
	fi

	mainMenu
}

function renameDB() {
	listDBs "skipMainMenu"

	readValidName "$PROMPT_READ_DB_NAME"
	oldDB=$(retrieveValidatedInput)

	readValidName "$PROMPT_READ_DB_NAME"
	newDB=$(retrieveValidatedInput)

	if mv "$RECORDS_DIRECTORY/$oldDB" "$RECORDS_DIRECTORY/$newDB"; then
		printSuccess "$PROMPT_DB_RENAMING_DONE"
	else
		printError "$PROMPT_DB_RENAMING_ERROR"
	fi

	mainMenu
}

function deleteDB() {
	listDBs "skipMainMenu"

	readValidName "$PROMPT_READ_DB_NAME"
	dbName=$(retrieveValidatedInput)

	dbPath="$RECORDS_DIRECTORY/$dbName"

	if confirmChoice "$dbName:\n\t $PROMPT_DELETION_CONFIRM"; then
		if rm -r "$dbPath" 2>>/dev/null; then
			printSuccess "$PROMPT_DB_DELETION_DONE"
		else
			printError "$PROMPT_DB_DELETION_ERROR"
		fi
	else
		printWarning "$PROMPT_DB_DELETION_CANCELLED"
	fi

	mainMenu
}

mainMenu
