#!/usr/bin/env bash
# shellcheck disable=all

# Initilization Variables
RECORDS_DIRECTORY=".records"

# Styling
NC='\033[0m'
Yellow='\033[0;33m'
On_IGreen='\033[0;102m'
On_IRed='\033[0;101m'

# Select Menu Options
CREATE_DATABASE="Create database"
LIST_DATABASE="List database"
CONNECT_TO_DATABASE="Connect to a database"
RENAME_DATABASE="Rename a database"
DELETE_DATABASE="Delete Database"
EXIT="Exit"

# Prompt Messages
INVALID_INPUT="Invalid Input!"