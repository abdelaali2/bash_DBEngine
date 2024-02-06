#!/usr/bin/env bash

# Initilization Variables
export DB_ENGINE=".dbEngine.sh"
export RECORDS_DIRECTORY=".records"

# Styling
export STYLE_NC='\033[0m'
export STYLE_YELLOW='\033[0;33m'
export STYLE_ON_IRED='\033[0;101m'
export STYLE_ON_IGREEN='\033[0;102m'
export STYLE_ON_IYELLOW='\033[0;103m'

# Main Menu Select Options
export LIST_DB="List databases"
export CREATE_DB="Create database"
export DELETE_DB="Delete Database"
export RENAME_DB="Rename a database"
export CONNECT_TO_DB="Connect to a database"

# Table Menu Select Options
export DROP_TABLE="Drop table"
export LIST_TABLES="List tables"
export CREATE_TABLE="Create table"
export UPDATE_TABLE="Update table"
export INSERT_INTO_TABLE="Insert into table"
export SELECT_FROM_TABLE="Select from table"
export DELETE_FROM_TABLE="Delete from table"

# General Select Options
export EXIT="Exit"
export RETURN="Return"

# Main Menu Prompt Messages
export PROMPT_INVALID_INPUT="Invalid Input!"
export PROMPT_READ_DB_NAME="Enter the database name: "
export PROMPT_WELCOME="WELCOME\n"
export PROMPT_WELCOME_BACK="WELCOME BACK\n"
export PROMPT_DB_CREATION_DONE="Database created successfully\n"
export PROMPT_DB_DUPLICATE_ERROR="Error: Database already exists\n"
export PROMPT_DB_NOT_FOUND="Error: Database not found\n"
export PROMPT_INAVLID_DB_NAME="Invalid database name. It must not start with a number or a special character\n"
export PROMPT_CURRENT_DBS="Current databases:\n"
export PROMPT_DB_RENAMING_DONE="Database renamed successfully\n"
export PROMPT_DB_RENAMING_ERROR="Error: Unable to rename the database\n"
export PROMPT_DELETION_CONFIRM="The database will be deleted permanently! Continue? (Yes/No): "
export PROMPT_NO_OPTION="No (N)"
export PROMPT_YES_OPTION="Yes (Y)"
export PROMPT_DB_DELETION_CANCELLED="Deletion cancelled\n"
export PROMPT_DB_DELETION_DONE="Database deleted successfully\n"
export PROMPT_DB_DELETION_ERROR="Error: Unable to delete the database\n"

# Table Menu Prompt Messages
export PROMPT_CURRENT_TABLES="Tables:\n"
export PROMPT_READ_TABLE_NAME="Enter the table name: "
export PROMPT_READ_COL_NUMBER="Enter the number of columns: "
export PROMPT_INAVLID_TABLE_NAME="Invalid table name. It must not start with a number or a special character\n"
