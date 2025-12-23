#!/bin/bash

create_table() {
    echo -e "\n=== Create Table ===\n"
    
    read -r -p "Enter table name (start with letter, no spaces): " table_name
    table_name=$(echo "$table_name" | xargs)  # remove spaces

    # Validation
    if [ -z "$table_name" ]; then
        echo "Table name cannot be empty!"
        create_table
        return
    elif [[ "$table_name" =~ [[:space:]] ]]; then
        echo "Table name cannot contain spaces!"
        create_table
        return
    elif [ -f "$table_name.table" ]; then
        echo "Table '$table_name' already exists!"
        create_table
        return
    elif [[ ! "$table_name" =~ ^[a-zA-Z] ]]; then
        echo "Table name must start with a letter!"
        create_table
        return
    fi

    # Create files
    touch "$table_name.table"
    touch "metaData_$table_name"

    read -r -p "Enter number of columns: " col_count
    echo "Table Name: $table_name" > "metaData_$table_name"
    echo "Columns: $col_count" >> "metaData_$table_name"

    echo -e "\nDefine columns:\n"
    header="|"

    for ((i=1; i<=col_count; i++)); do
        read -r -p "Column $i name: " col_name
        col_name=$(echo "$col_name" | tr ' ' '_')  # replace spaces with underscores

        if [ $i -eq 1 ]; then
            col_type="int"
            echo "Primary Key (column $i) set to int by default"
            echo "primary_key:$col_name:$col_type" >> "metaData_$table_name"
        else
            echo "Select type for $col_name:"
            select col_type in "int" "str" "bool"; do
                case $col_type in
                    int|str|bool) break ;;
                    *) echo "Invalid choice!" ;;
                esac
            done
            echo "column:$col_name:$col_type" >> "metaData_$table_name"
        fi

        # Build header line for table
        header="$header $(printf '%-10s' "$col_name") |"
    done

    # Write header to table file
    echo "$header" >> "$table_name.table"
    echo "$(printf '%0.s-' {1..${#header}})" >> "$table_name.table"  # separator line

    echo -e "\nTable '$table_name' created successfully!\n"
}

