#!/bin/bash

DB_DIR="./databases"
mkdir -p "$DB_DIR"
# UI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'   # Reset
create_database() {
          # Header
    echo -e "${CYAN}+------------------------------+${NC}"
    printf "${CYAN}| %-28s |${NC}\n" " Create Database"
    echo -e "${CYAN}+------------------------------+${NC}"


    read -r -p "Enter database name: " db_name

    if [[ -z "$db_name" ]]
    then
            echo -e "${RED} Invalid database name.${NC} "
            echo -e  "${RED}  Must not be empty.${NC} "
            return
    fi

    if [[ "$db_name" == *" "* ]]
    then
            echo -e  " ${RED} Invalid database name. ${NC} "
            echo -e  " ${RED} Must not conatin spaces . ${NC} "
            return
    fi

    if [[ "$db_name" != [a-zA-Z]* ]]
    then
            echo -e " ${RED} Invalid database name. ${NC} "
            echo -e  "${RED} Must start with an alphabetic character.${NC} "
            return
    fi

    if [ -d "$DB_DIR/$db_name" ];
    then
        echo -e  "${RED}  Database '$db_name' already exists.${NC} "
    else
        mkdir "$DB_DIR/$db_name"
        echo -e "${GREEN}  Database '$db_name' created successfully.${NC} "
    fi
}


