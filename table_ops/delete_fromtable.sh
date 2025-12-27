#!/bin/bash
# UI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

delete_fromtable() {
   
 # Header box
    echo -e "${CYAN}+--------------------------------------+${NC}"
    printf "${CYAN}| %-36s |\n" " Delete From Table "
    echo -e "${CYAN}+--------------------------------------+${NC}"
    echo

    # List tables
    tables=(*.table)
    if [ ${#tables[@]} -eq 0 ]; then
        echo -e "${RED}  No tables found in this database .${NC} "
        return
    fi


    # Let user select a table using a menu
  echo -e "Select a table to delete from:"
  echo

  PS3="Enter the number of the table: "  # Prompt for select
  select t in "${tables[@]}"; do
    if [[ -n "$t" ]]; then
        table_name="${t%.table}"  # Remove .table extension
        echo "You selected table: $table_name"
        break
    else
        echo -e  "${RED}  Invalid choice, try again.${NC} "
    fi
 done

    # Ask for primary key value to delete
    meta_file="metaData_$table_name"
    if [ ! -f "$meta_file" ]; then
        echo -e "${RED} Metadata for '$table_name' not found!${NC} "
        return
    fi
    primary_key=""
    pk_type=""
    # Find primary key column name from metadata
    while IFS=: read -r key name type; do
        if [[ "$key" == "primary_key" ]]; then
            primary_key="$name"
	    pk_type="$type"
            break
        fi
    done < <(tail -n +3 "$meta_file")

    if [ -z "$primary_key" ]; then
        echo -e "${RED} Primary key not found in metadata! ${NC} "
        return
    fi
   echo -e "\nPrimary Key Information:"
    echo "- Column Name : $primary_key"
    echo "- Data Type   : $pk_type"
    echo

    
    # Ask user for PK value
    while true; do
           read -r -p "$(echo -e "${YELLOW}Enter the primary key value to delete: ${NC}")" pk_val

        if [ -z "$pk_val" ]; then
            echo -e  "${RED}  Primary key value cannot be empty! ${NC} "
            continue
        fi

        # Type validation
        if [[ "$pk_type" == "int" ]] && ! [[ "$pk_val" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}   Invalid input. Expected integer.  ${NC} "
            continue
        fi

        break
    done

    # Check if row exists
    if ! grep -q "^| *$pk_val *|" "$table_name.table"; then
        echo -e  "${RED}   No row found with primary key '$pk_val'. ${NC}  "
        return
    fi

    # Confirmation
   read -r -p "$(echo -e "${RED}Are you sure you want to delete this row? [y/n]: ${NC}")" confirm

  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Delete operation canceled."
    return
  fi
  

    # Delete row
    awk -v pk="$pk_val" -F'|' '
        NR<=2 {print; next}
        $2 !~ "^[[:space:]]*" pk "[[:space:]]*$" {print} ' "$table_name.table" > temp_file

    mv temp_file "$table_name.table"
    echo -e "${GREEN} Row with primary key '$pk_val' deleted successfully! ${NC}  "
}



