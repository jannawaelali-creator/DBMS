#!/bin/bash

# UI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

list_tables() {
   clear 
    
    # Header box
    echo -e "${CYAN}+--------------------------------------+${NC}"
    printf "${CYAN}| %-36s |\n" " Tables in Current Database "
    echo -e "${CYAN}+--------------------------------------+${NC}"
    echo

     
    
    # Find all files ending with .table
    tables=(*.table)
    
    if [ ${#tables[@]} -eq 0  ]; then
         echo " ${RED}  No tables found in this database .${NC} "
    else 
         # Print header in white
        printf "%-3s %-30s\n" "No." "Table Name"
        echo "--------------------------------------"
        i=1
        for t in "${tables[@]}"; do
            # Table names in normal white
            printf "%-3s %-30s\n" "$i" "${t%.table}"
            ((i++))
        done
    fi
    
   
}
