#!/usr/bin/env bash

# Initilization Variables
export DB_ENGINE=".dbEngine.sh"
export RECORDS_DIRECTORY=".records"

# Styling
export STYLE_NC='\033[0m'
export STYLE_YELLOW='\033[0;33m'
export STYLE_ON_IRED='\033[0;101m'
export STYLE_ON_IGREEN='\033[0;102m'

# Select Menu Options
export EXIT="Exit"
export LIST_DB="List databases"
export CREATE_DB="Create database"
export DELETE_DB="Delete Database"
export RENAME_DB="Rename a database"
export CONNECT_TO_DB="Connect to a database"

# Prompt Messages
export PROMPT_INVALID_INPUT="Invalid Input!"
export PROMPT_READ_DB_NAME="Enter database name: "
export PROMPT_WELCOME="WELCOME\n"
export PROMPT_WELCOME_BACK="WELCOME BACK\n"
export PROMPT_DB_CREATION_DONE="Database created successfully\n"
export PROMPT_DB_DUPLICATE_ERROR="Database already exists\n"
export PROMPT_DB_NOT_FOUND="Database not found\n"
export PROMPT_INAVLID_DB_NAME="Invalid,database name must not export start with a number or a special character\n"
export PROMPT_CURRENT_DBS="Current databases:\n"
export PROMPT_DB_RENAMING_DONE="Database renamed successfully\n"
export PROMPT_DB_RENAMING_ERROR="Error: Unable to rename the export database\n"
export PROMPT_DELETION_CONFIRM="will be deleted permenantely! export Continue?\n"
export PROMPT_NO_OPTION="No"
export PROMPT_YES_OPTION="Yes"
export PROMPT_DB_DELETION_CANCELLED="Deletion cancelled"
export PROMPT_DB_DELETION_DONE="Database deleted successfully\n"
export PROMPT_DB_DELETION_ERROR="Error: Unable to delete the database\n"
