#!/usr/bin/env bash
# shellcheck disable=all

# Initilization Variables
RECORDS_DIRECTORY=".records"
DB_ENGINE="$RECORDS_DIRECTORY/.dbEngine.sh"

# Styling
STYLE_NC='\033[0m'
STYLE_YELLOW='\033[0;33m'
STYLE_ON_IGREEN='\033[0;102m'
STYLE_ON_IRED='\033[0;101m'

# Select Menu Options
CREATE_DB="Create database"
LIST_DB="List database"
CONNECT_TO_DB="Connect to a database"
RENAME_DB="Rename a database"
DELETE_DB="Delete Database"
EXIT="Exit"

# Prompt Messages
PROMPT_INVALID_INPUT="Invalid Input!"
PROMPT_READ_DB_NAME="Enter database name: "
PROMPT_WELCOME="WELCOME\n\n"
PROMPT_WELCOME_BACK="WELCOME BACK\n\n"
PROMPT_DB_CREATION_DONE="Database created successfully\n"
PROMPT_DB_DUPLICATE_ERROR="Database already exists\n"
PROMPT_DB_NOT_FOUND="Database not found\n"
