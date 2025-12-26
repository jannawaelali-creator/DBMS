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

    
# Read each column line directly
    while IFS=: read -r key name type; do
    col_names+=("$name")
    col_types+=("$type")
    if [[ "$key" == "primary_key" ]]; then
        primary_key="$name"
    fi
 done < <(tail -n +3 "$meta_file")



    # Insert values
    values=()
    for i in "${!col_names[@]}"; do
        while true; do
            prompt="Enter value for column '${col_names[i]}' (${col_types[i]}): "
            if [[ "${col_names[i]}" == "$primary_key" ]]; then
                prompt="Enter value for PRIMARY KEY '${col_names[i]}' (${col_types[i]}, must be unique & not null): "
            fi

            read -r -p "$prompt" val

            # Not null check for primary key
            if [[ "${col_names[i]}" == "$primary_key" && -z "$val" ]]; then
                echo "Primary key cannot be empty!"
                continue
            fi

            # Type check
            if [[ "${col_types[i]}" == "int" ]] && ! [[ "$val" =~ ^[0-9]+$ ]]; then
                echo "Invalid integer. Try again."
                continue
            elif [[ "${col_types[i]}" == "str" ]] && [[ -z "$val" ]]; then
                echo "String cannot be empty."
                continue
            fi

            # Unique check for primary key
           # Unique check for primary key
          if [[ "${col_names[i]}" == "$primary_key" ]]; then
                 if grep -q "^| *$val *|" "$table_name.table"; then
                 echo "Primary key '$primary_key' must be unique! Value already exists."
                continue
            fi
        fi


            break
        done
        values+=("$val")
    done

    # Format row and append to table
    row="|"
    for val in "${values[@]}"; do
        row="$row $(printf '%-20s' "$val") |"
    done

    echo "$row" >> "$table_name.table"
    echo "Row inserted successfully into '$table_name'."
}

