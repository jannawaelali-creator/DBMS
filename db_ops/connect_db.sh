#!/bin/bash
source ./table_ops/create_table.sh
source ./table_ops/list_table.sh
source ./table_ops/insert_table.sh
source ./table_ops/drop_table.sh
source ./table_ops/delete_fromtable.sh
source ./table_ops/update_table.sh
source ./table_ops/select_from_table.sh
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DB_PATH="./databases"

# Function for the connected database menu
connected_db_menu() {
    local db_name="$1"
    while true; do
        
  echo -e "${CYAN}+--------------------------------------+${NC}"
  printf "${CYAN}| %-36s |${NC}\n" "connected to Database: $db_name"
  echo -e "${CYAN}+--------------------------------------+${NC}"

       

        # Menu options inside the box
        printf "| %-36s |\n" "1. Create Table"
        printf "| %-36s |\n" "2. List Tables"
        printf "| %-36s |\n" "3. Drop Table"
        printf "| %-36s |\n" "4. Insert Into Table"
        printf "| %-36s |\n" "5. Select From Table"
        printf "| %-36s |\n" "6. Delete From Table"
        printf "| %-36s |\n" "7. Update Table"
        printf "| %-36s |\n" "8. Exit"

        echo -e "${CYAN}+--------------------------------------+${NC}"

        read -r -p "Choose: " choice
        choice="${choice//[[:space:]]/}"
        case $choice in
            1) create_table  ;;
            2) list_tables  ;;
            3) drop_table  ;;
            4) insert_table  ;;
            5) select_table ;;
            6) delete_fromtable  ;;
            7)update_table ;; 
            8) break ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;

        esac
        echo 
        read -r -p "Press any key to continue... " -n1 -s
        echo
    done
}

# Function to connect to a database
connect_to_database() {
    clear

    # Count number of directories (databases) inside $DB_PATH
    number_db=$(ls -1 $DB_PATH | wc -l)


    if [ "$number_db" -eq 0 ]; then
        echo -e  "${RED} No databases found. Create one first ${NC}."
        return
    else
     echo -e "${CYAN}+------------------------------+${NC}"
    printf "${CYAN}| %-28s |${NC}\n" " Available Databases"
    echo -e "${CYAN}+------------------------------+${NC}"

        ls "$DB_PATH"
    fi
   echo
    read -r -p "Enter the database name to connect: " db_name
    db_name=$(echo "$db_name" | xargs)   # trim spaces

    # Empty check
    if [[ -z "$db_name" ]]; then
        echo -e "${RED} Invalid database name. Must not be empty${NC} ."
        return
    fi

    # Space check
    if [[ "$db_name" == *" "* ]]; then
        echo -e "${RED} Invalid database name. Must not contain spaces${NC} ."
        return
    fi

    # Must start with a letter
    first_char="${db_name:0:1}"
    if [[ ! "$first_char" =~ [a-zA-Z] ]]; then
        echo -e "${RED} Invalid database name. Must start with a letter ${NC} ."
        return
    fi

    # Check if database exists
    if [ -d "$DB_PATH/$db_name" ]; then
	echo 
        echo -e "${GREEN}................ Connecting to database '$db_name'.....................${NC} "
	echo
        cd "$DB_PATH/$db_name" || exit
        connected_db_menu "$db_name"
        echo "Return to main directory...."
        cd - || exit
    else
        echo -e "${RED} Database '$db_name' does not exist.${NC} "
    fi
}





 
