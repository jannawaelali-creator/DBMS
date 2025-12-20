#!/bin/bash

DB_PATH="./databases"

# Function for the connected database menu
connected_db_menu() {
    local db_name="$1"
    while true; do
        
        echo "Database '$db_name' Menu"
        echo "----------------------"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert Into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo "8. Exit"
        echo "----------------------"

        read -r -p "Choose: " choice

        case $choice in
            1) ./table_ops/create_table.sh "$DB_PATH/$db_name" ;;
            2) ./table_ops/list_tables.sh "$DB_PATH/$db_name" ;;
            3) ./table_ops/drop_table.sh "$DB_PATH/$db_name" ;;
            4) ./table_ops/insert_table.sh "$DB_PATH/$db_name" ;;
            5) ./table_ops/select_table.sh "$DB_PATH/$db_name" ;;
            6) ./table_ops/delete_table.sh "$DB_PATH/$db_name" ;;
            7) ./table_ops/update_table.sh "$DB_PATH/$db_name" ;;
            8) break ;;
            *) echo "Invalid option" ;;
        esac

        read -r -p "Press any key to continue..." -n1 -s
    done
}

# Function to connect to a database
#connect_to_database() {
    echo "Available Databases:"
    ls "$DB_PATH"

    read -r -p "Enter the database name to connect: " db_name

    if [ -d "$DB_PATH/$db_name" ]; then
        echo "Connecting to database '$db_name'..."
        cd "$DB_PATH/$db_name" || exit
        connected_db_menu "$db_name"   # Call the menu function for the connected database
        cd - || exit                   # Return to previous directory after disconnect
    else
        echo "Database '$db_name' does not exist."
    fi
#}

# Run the connect function
connect_to_database



