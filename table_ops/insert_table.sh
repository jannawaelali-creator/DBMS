#!/bin/bash

insert_table() {
    echo -e "\n=== Insert Into Table ===\n"

    # List available tables
    tables=(*.table)
    if [ ${#tables[@]} -eq 0 ]; then
        echo "No tables found in this database."
        return
    fi

  # Let user select a table using a menu
 echo -e "Select a table to insert into:"
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

    meta_file="metaData_$table_name"
    if [ ! -f "$meta_file" ]; then
        echo "Metadata for '$table_name' not found!"
        return
    fi

col_names=()
col_types=()
primary_key=""
  
# Read each column line directly
    while IFS=: read -r key name type; do
    col_names+=("$name")
    col_types+=("$type")
    if [[ "$key" == "primary_key" ]]; then
        primary_key="$name"
    fi
 done < <(tail -n +3 "$meta_file")

temp_values=()

for i in "${!col_names[@]}"; do
    while true; do

        if [[ "${col_names[i]}" == "$primary_key" ]]; then
            prompt="Enter value for PRIMARY KEY '${col_names[i]}' (${col_types[i]}): "
        else
            prompt="Enter value for column '${col_names[i]}' (${col_types[i]}): "
        fi

        read -r -p "$prompt" val

        # Ctrl+D (EOF) → cancel safely
        if [[ $? -ne 0 ]]; then
            echo -e "\nInsert canceled."
            return
        fi

        # Primary key not null
        if [[ "${col_names[i]}" == "$primary_key" && -z "$val" ]]; then
            echo "Primary key cannot be empty. Try again."
            continue
        fi

        # Type validation
        if [[ "${col_types[i]}" == "int" ]];then
	    if ! [[ "$val" =~ ^[0-9]+$ ]]; then
             echo "Invalid integer. Try again."
             continue
        fi
	 # primary key cannot be zero
    if [[ "${col_names[i]}" == "$primary_key" && "$val" -eq 0 ]]; then
        echo "Primary key cannot be zero!"
        continue
    fi
 fi

  

       if [[ "${col_types[i]}" == "str" ]]; then
    if [[ -z "$val" ]]; then
        echo "String cannot be empty."
        continue
    elif [[ "$val" == *"|"* ]]; then
        echo "String cannot contain the '|' character."
        continue
    fi
    fi


        # PK uniqueness
        if [[ "${col_names[i]}" == "$primary_key" ]]; then
            if awk -F'|' -v v="$val" '
                NR>2 {
                    gsub(/^[ \t]+|[ \t]+$/, "", $2)
                    if ($2 == v) exit 1
                }
            ' "$table_name.table"
            then
                :
            else
                echo "Primary key already exists. Try again."
                continue
            fi
        fi

        # value accepted
        temp_values+=("$val")
        break
    done
done


   
    # Format row and append to table
    row="|"
    for val in "${temp_values[@]}"; do
        row="$row $(printf '%-20s' "$val") |"
    done

    echo "$row" >> "$table_name.table"
    echo "Row inserted successfully into '$table_name'."
}
