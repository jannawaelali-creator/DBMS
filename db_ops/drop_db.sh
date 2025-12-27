#!/bin/bash

DB_DIR="./databases"
# Ensure databases folder exists
mkdir -p "$DB_DIR"
# UI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'   # Reset


 drop_database(){
    echo -e "${CYAN}+------------------------------+${NC}"
    printf "${CYAN}| %-28s |${NC}\n" " Available Databases"
    echo -e "${CYAN}+------------------------------+${NC}"
	 ls $DB_DIR
echo
read -p "Enter database name to drop: " db_name

  db_name=$(echo "$db_name" | xargs)  # trim spaces

        # Check if empty
        if [[ -z "$db_name" ]]; then
            echo -e "${RED} Invalid database name. Must not be empty.${NC} "
            return
        fi

        # Check for spaces
        if [[ "$db_name" == *" "* ]]; then
            echo -e "${RED} Invalid database name. Must not contain spaces.${NC} "
            return
        fi

        # Check if starts with a letter
        if [[ ! "$db_name" =~ ^[a-zA-Z] ]]; then
            echo -e "${$RED} Invalid database name. Must start with a letter.${NC} "
            return
        fi



   if [ -d "$DB_DIR/$db_name" ]
     then
      while true; do
	    echo
        read -r -p "$(echo -e "${RED}Are you sure you want to delete database '$db_name'? [y/n]: ${NC}")" confirm

        case "$confirm" in
            [Yy])
                rm -r "$DB_DIR/$db_name"
                echo -e "${GREEN} Database '$db_name' has been deleted.${NC} "
                break
                ;;
            [Nn])
                echo -e "${RED} Operation cancelled.${NC} "
                break
                ;;
            *)
                echo "${RED} Invalid input. Please enter 'y' for yes or 'n' for no.${NC} "
                ;;
        esac
    done
else
    echo -e "${RED} Database '$db_name' does not exist.${NC} "
fi

}


