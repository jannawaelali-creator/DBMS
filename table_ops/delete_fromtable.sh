#!/bin/bash

delete_fromtable() {
    echo -e "\n=== Delete From Table ===\n"

    # List tables
    tables=(*.table)
    if [ ${#tables[@]} -eq 0 ]; then
        echo "No tables found in this database."
        return
    fi


    # Let user select a table using a menu
  echo -e "Select a table to delete into:"
  PS3="Enter the number of the table: "  # Prompt for select
  select t in "${tables[@]}"; do
    if [[ -n "$t" ]]; then
        table_name="${t%.table}"  # Remove .table extension
        echo "You selected table: $table_name"
        break
    else
        echo "Invalid choice, try again."
    fi
 done

    # Ask for primary key value to delete
    meta_file="metaData_$table_name"
    if [ ! -f "$meta_file" ]; then
        echo "Metadata for '$table_name' not found!"
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
        echo "Primary key not found in metadata!"
        return
    fi
   echo -e "\nPrimary Key Information:"
    echo "- Column Name : $primary_key"
    echo "- Data Type   : $pk_type"
    echo

    
    # Ask user for PK value
    while true; do
        read -r -p "Enter the primary key value to delete: " pk_val

        if [ -z "$pk_val" ]; then
            echo "Primary key value cannot be empty!"
            continue
        fi

        # Type validation
        if [[ "$pk_type" == "int" ]] && ! [[ "$pk_val" =~ ^[0-9]+$ ]]; then
            echo "Invalid input. Expected integer."
            continue
        fi

        break
    done

    # Check if row exists
    if ! grep -q "^| *$pk_val *|" "$table_name.table"; then
        echo "No row found with primary key '$pk_val'."
        return
    fi

    # Confirmation
  read -r -p "Are you sure you want to delete the row with primary key '$pk_val'? (y/n): " confirm

  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Delete operation canceled."
    return
  fi
    # Delete row
    awk -v pk="$pk_val" -F'|' '
        NR<=2 {print; next}
        $2 !~ "^[[:space:]]*" pk "[[:space:]]*$" {print} ' "$table_name.table" > temp_file

    mv temp_file "$table_name.table"
    echo "Row with primary key '$pk_val' deleted successfully!"
}



