#!/usr/bin/env bash

# Initilization Variables
export DB_ENGINE=".dbEngine.sh"
export RECORDS_DIRECTORY=".records"
export VALIDATION_STATE=".valid.temp"

# Styling
export STYLE_NC='\033[0m'
export STYLE_BLUE='\033[0;34m'
export STYLE_YELLOW='\033[0;33m'
export STYLE_ON_IRED='\033[0;41m'
export STYLE_ON_IWHITE='\033[0;55m'
export STYLE_ON_IGREEN='\033[0;42m'
export STYLE_ON_IMAGENTA='\033[0;46m'

# Main Menu Options
export LIST_DB="List databases"
export CREATE_DB="Create database"
export DELETE_DB="Delete database"
export RENAME_DB="Rename database"
export CONNECT_TO_DB="Connect to database"

# Table Menu Options
export DROP_TABLE="Drop table"
export LIST_TABLES="List tables"
export CREATE_TABLE="Create table"
export UPDATE_TABLE="Update table"
export INSERT_INTO_TABLE="Insert into table"
export SELECT_FROM_TABLE="Select from table"
export DELETE_FROM_TABLE="Delete from table"

# Table Menu Scripts
export SCRIPT_CREATE_TABLE=".createTable.sh"
export SCRIPT_LIST_TABLES=".listTables.sh"
export SCRITPT_DROP_TABLE=".dropTable.sh"
export SCRIPT_INSERT_INTO_TABLE=".insertIntoTable.sh"
export SCRIPT_SELECT_FROM_TABLE=".selectFromTable.sh"
export SCRIPT_DELETE_FROM_TABLE=".deleteFromTable.sh"

# Table Selection Menu Options
export SELECT_ALL="Select all"
export SELECT_ENTIRE_COLUMN="Select entire column"
export SELECT_ENTIRE_ROW="Select entire row"
export SELECT_CERTAIN_VALUES="Select certain values"

# Table Deletion Menu Options
export DELETE_TABLE="Delete table"
export DELETE_ENTIRE_ROW="Delete row"
export DELETE_CERTAIN_VALUES="Delete certain values"

# General Select Options
export EXIT="Exit"
export RETURN="Return"

# Global Prompt Messages
export PROMPT_INVALID_INPUT="Invalid input!"
export PROMPT_INVALID_NAME="Invalid name! It must not start with a number or a special character\n"
export PROPMPT_ENTER_TO_CONTINUE="Press 'Enter' to proceed"
export PROMPT_EMPTY_SET="Empty set!\n"
export PROMPT_RECORDS_FOUND="No. of found records: "

# Main Menu Prompt Messages
export PROMPT_READ_DB_NAME="Enter the database name: "
export PROMPT_WELCOME="WELCOME\n"
export PROMPT_WELCOME_BACK="WELCOME BACK\n"
export PROMPT_DB_CREATION_DONE="Database created successfully\n"
export PROMPT_DB_CREATION_ERROR="Error: Unable to create the database\n"
export PROMPT_DB_DUPLICATE_ERROR="Error: Database already exists\n"
export PROMPT_DB_NOT_FOUND_ERROR="Error: Database not found\n"
export PROMPT_CURRENT_DBS="Current databases:\n"
export PROMPT_READ_NEW_DB_NAME="Enter the new database name: "
export PROMPT_DB_RENAMING_DONE="Database renamed successfully\n"
export PROMPT_DB_RENAMING_ERROR="Error: Unable to rename the database\n"
export PROMPT_DELETION_CONFIRM="The database will be deleted permanently! Continue? (Yes/No): "
export PROMPT_NO_OPTION="No (N)"
export PROMPT_YES_OPTION="Yes (Y)"
export PROMPT_DB_DELETION_CANCELLED="Database deletion cancelled\n"
export PROMPT_DB_DELETION_DONE="Database deleted successfully\n"
export PROMPT_DB_DELETION_ERROR="Error: Unable to delete the database\n"

# Table Menu Prompt Messages
export PROMPT_CURRENT_TABLES="Tables:\n"
export PROMPT_READ_TABLE_NAME="Enter the table name: "
export PROMPT_READ_COL_NUMBER="Enter the number of columns: "
export PROMPT_READ_COL_NAME="Enter the name of column no."
export PROMPT_READ_COL_TYPE="Choose the type of the column"
export PROMPT_ASSIGN_AS_PK="Assign this column as the pk?  (Yes/No): "
export PROMPT_TABLE_CREATION_DONE="Table Created Successfully\n"
export PROMPT_TABLE_CREATION_ERROR="Error: Unable to create the table\n"
export PROPMPT_TABLE_DELETEION_CONFIRM="The table will be deleted permanently! Continue? (Yes/No): "
export PROMPT_TABLE_DELETION_CANCELLED="Table deletion cancelled\n"
export PROMPT_TABLE_DELETION_DONE="Table deleted successfully\n"
export PROMPT_TABLE_DELETION_ERROR="Error: Unable to drop the table\n"
export PROMPT_TABLE_NOT_FOUND="Error: Table not found\n"
export PROMPT_INVALID_DATATYPE_ERROR="Error: Invalid datatype! Expected:"
export PROMPT_PK_DUPLICATE_ERROR="Error: Duplicate primary key violation!\n"
export PROMPT_PK_NULL_ERROR="Error: Null primary key violation!\n"
export PROMPT_DATA_INSERTION_DONE="Data inserted successfully\n"
export PROMPT_DATA_INSERTION_ERROR="Error: Unable to insert data\n"

# Table Selection Menu Prompt Messages
export PROMPT_EXISTING_COLS="Existing columns:"
export PROMPT_SELECT_COL="Select column number: "
export PROMPT_COL_OUTBOUND_ERROR="Error: Index outbound!\n"
export PROMPT_ENTER_QUERY="Enter your search query: "
export PROMPT_QUERY_DONE="Query OK!\n"

# Table Data Deletion Menu
export PROMPT_DATA_DELETION_CONFIRM="All data will be deleted permanently! Continue? (Yes/No): "
export PROMPT_DATA_DELETION_DONE="Data deleted successfully\n"
export PROMPT_DATA_DELETION_ERROR="ERROR: Unable to delete data\n"
export PROMPT_DATA_DELETION_CANCELLED="Data deletion cancelled"
export PROMPT_DATA_OCCURRENCIES_DELETION_CONFIRM="record(s) will be deleted permanently! Continue? (Yes/No): "

# Data Constants
export DATA_SEPARATOR=":"
export DATA_NEW_LINE="\n"
export DATA_HEADER="Field${DATA_SEPARATOR}Type${DATA_SEPARATOR}PK${DATA_NEW_LINE}"
export DATA_INTEGER="Integer"
export DATA_STRING="String"

# REGEXP Constants
export REGEX_NAMES="^[a-zA-Z][a-zA-Z0-9]*$"
export REGEX_ANY_NUMBER="-?[0-9]+(\.[0-9]+)?"
export REGEX_POSITIVE_NUMBERS="^([1-9][0-9]*)$"
