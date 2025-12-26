#!/bin/bash

create_table() {
    echo -e "\n=== Create Table ===\n"

    # ---------------- Table name ----------------
    read -r -p "Enter table name (start with letter, no spaces): " table_name
    table_name=$(echo "$table_name" | xargs)

    if [ -z "$table_name" ]; then
        echo "Table name cannot be empty!"
        create_table
    elif [[ "$table_name" =~ [[:space:]] ]]; then
        echo "Table name cannot contain spaces!"
        create_table
    elif [[ ! "$table_name" =~ ^[a-zA-Z] ]]; then
        echo "Table name must start with a letter!"
        return
    elif [ -f "$table_name.table" ]; then
        echo "Table already exists!"
        return
    fi

    # ---------------- Columns count ----------------
    read -r -p "Enter number of columns: " col_count

   if [ -z "$col_count" ]; then
    echo "Number of columns cannot be empty!"
    return
 fi

  if ! [[ "$col_count" -gt 0 ]]; then
    echo "Please enter a valid positive number!"
    return
 fi

    header="|"
    meta_lines=()
   col_names=()

    # ---------------- Columns loop ----------------
    for ((i=1; i<=col_count; i++)); do

        # ---- Column name validation ----
        while true; do
            read -r -p "Enter name for column $i: " col_name
            col_name=$(echo "$col_name" | xargs)

            if [ -z "$col_name" ]; then
                echo "Column name cannot be empty!"
            elif [[ "$col_name" =~ [[:space:]] ]]; then
                echo "Column name cannot contain spaces!"
            elif [[ ! "$col_name" =~ ^[a-zA-Z] ]]; then
                echo "Column name must start with a letter!"

	    elif [[ " ${col_names[@]} " =~ " $col_name " ]]; then
        echo "Column name '$col_name' already exists! Choose another name."
	   else
                break
            fi
        done

        # ---- Primary Key ----
        if [ "$i" -eq 1 ]; then
            echo "This column is the Primary Key"
            PS3="choose 1 or 2 based on what type you want:"  
            select choice in "int" "str"; do
                case $REPLY in
                    1) col_type="int"; break ;;
                    2) col_type="str"; break ;;
                    *) echo "Invalid choice!" ;;
                esac
            done

            meta_lines+=("primary_key:$col_name:$col_type")
	    col_names+=("$col_name")

        # ---- Normal columns ----
        else
		PS3="choose 1 or 2 based on what type you want:"

            select choice in "int" "str"; do
                case $REPLY in
                    1) col_type="int"; break ;;
                    2) col_type="str"; break ;;
                    *) echo "Invalid choice!" ;;
                esac
            done

            meta_lines+=("column:$col_name:$col_type")
	    col_names+=("$col_name")
        fi

        header="$header $(printf '%-20s' "$col_name") |"
    done

    # ---------------- Create files AFTER success ----------------
    touch "$table_name.table"
    touch "metaData_$table_name"

    {
        echo "Table Name: $table_name"
        echo "Columns: $col_count"
        printf "%s\n" "${meta_lines[@]}"
    } > "metaData_$table_name"

    echo "$header" >> "$table_name.table"
    echo "$(printf '%0.s-' {1..${#header}})" >> "$table_name.table"

    echo -e "\nTable '$table_name' created successfully!\n"
}


