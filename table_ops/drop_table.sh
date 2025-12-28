#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'   # Reset

drop_table() {

    shopt -s nullglob

    echo -e "\n${CYAN}=== Drop Table ===${NC}\n"

    # List available tables
    tables=(*.table)

    if [ ${#tables[@]} -eq 0 ]; then
        echo -e "${RED}No tables found in this database.${NC}"
        shopt -u nullglob
        return
    fi

    echo -e "${CYAN}Available Tables:${NC}"
    PS3="$(echo -e "Enter the number of the table to drop: ")"

    select t in "${tables[@]}" "Exit"; do
        if [[ "$t" == "Exit" ]]; then
            echo -e "${RED}Cancelled table deletion.${NC}"
            shopt -u nullglob
            return

        elif [[ -n "$t" ]]; then
            table_name="${t%.table}"
            break

        else
            echo -e "${RED}Invalid choice, try again.${NC}"
        fi
    done

    # Confirm deletion
    while true; do
        read -r -p "$(echo -e "${RED}Are you sure you want to delete table '$table_name'? [y/n]: ${NC}")" confirm

        case "$confirm" in
            [Yy])
                rm -f "$table_name.table" "metaData_$table_name"
                echo -e "${GREEN}Table '$table_name' has been deleted successfully.${NC}"
                break
                ;;
            [Nn])
                echo -e "${RED}Operation cancelled.${NC}"
                break
                ;;
            *)
                echo -e "${RED}Invalid input. Please enter 'y' for yes or 'n' for no.${NC}"
                ;;
        esac
    done

    shopt -u nullglob
}

