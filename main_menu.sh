#!/bin/bash
source ./db_ops/connect_db.sh
source ./db_ops/create_db.sh
source ./db_ops/drop_db.sh
source ./db_ops/list_db.sh
# Colors
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"
BOLD="\e[1m"

main_menu()
{
while true;do
	clear

   
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════╗"
    echo "║          SIMPLE DBMS              ║"
    echo "╠══════════════════════════════════╣"
    echo "║  1) Create Database               ║"
    echo "║  2) List Databases                ║"
    echo "║  3) Connect to Database           ║"
    echo "║  4) Drop Database                 ║"
    echo "║  5) Exit                          ║"
    echo "╚══════════════════════════════════╝"
    echo -e "${RESET}"

    echo -ne "${YELLOW}Enter your choice [1-5]: ${RESET}"
    read -r choice
    choice="${choice//[[:space:]]/}"

    case "$choice" in
        1) create_database ;;
        2) list_databases ;;
        3) connect_to_database ;;
        4) drop_database ;;
        5) echo -e "${GREEN}Goodbye 👋${RESET}"; exit 0 ;;
        *)
            echo -e "${RED}❌ Invalid choice! Please enter 1-5.${RESET}"
            ;;
    esac

    echo
    read -r -p "Press Enter to return to main menu..." -n1 -s
done

}


main_menu






























