#!/bin/bash

DB_DIR="./databases"

mkdir -p "$DB_DIR"

 # UI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'   # Reset 

list_databases() {

    if [ "$(ls "$DB_DIR")" ]
    then
    echo -e "${CYAN}+------------------------------+${NC}"
    printf "${CYAN}| %-28s |${NC}\n" " Available Databases"
    echo -e "${CYAN}+------------------------------+${NC}"
            ls "$DB_DIR"
    else    
	    echo
	    echo -e  "${RED} No databases found.${NC} "
    fi
    echo
   
}



