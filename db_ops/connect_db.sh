#!/bin/bash
source ./table_ops/create_table.sh
source ./table_ops/list_table.sh
source ./table_ops/insert_table.sh
source ./table_ops/drop_table.sh
source ./table_ops/delete_fromtable.sh


DB_PATH="./databases"

# Function for the connected database menu
connected_db_menu() {
    local db_name="$1"
    while true; do
        clear

        # Create top border
        echo "+--------------------------------------+"
        printf "| %-36s |\n" "Connected to Database: $db_name"
        echo "+--------------------------------------+"

        # Menu options inside the box
        printf "| %-36s |\n" "1. Create Table"
        printf "| %-36s |\n" "2. List Tables"
        printf "| %-36s |\n" "3. Drop Table"
        printf "| %-36s |\n" "4. Insert Into Table"
        printf "| %-36s |\n" "5. Select From Table"
        printf "| %-36s |\n" "6. Delete From Table"
        printf "| %-36s |\n" "7. Update Table"
        printf "| %-36s |\n" "8. Exit"

        # Bottom border
        echo "+--------------------------------------+"

        read -r -p "Choose: " choice

        case $choice in
            1) create_table  ;;
            2) list_tables  ;;
            3) drop_table  ;;
            4) insert_table  ;;
            5) ./table_ops/select_table.sh "$DB_PATH/$db_name" ;;
            6) delete_fromtable  ;;
            7) ./table_ops/update_table.sh "$DB_PATH/$db_name" ;;
            8) break ;;
            *) echo "Invalid option" ;;
        esac
        echo 
        read -r -p "Press any key to continue... " -n1 -s

    done
}

# Function to connect to a database
connect_to_database() {
    clear

    # Count number of directories (databases) inside $DB_PATH
    number_db=$(ls -1 $DB_PATH | wc -l)


    if [ "$number_db" -eq 0 ]; then
        echo "No databases found. Create one first."
        return
    else
        echo "Available Databases:"
        ls "$DB_PATH"
    fi

    read -r -p "Enter the database name to connect: " db_name
    db_name=$(echo "$db_name" | xargs)   # trim spaces

    # Empty check
    if [[ -z "$db_name" ]]; then
        echo "Invalid database name. Must not be empty."
        return
    fi

    # Space check
    if [[ "$db_name" == *" "* ]]; then
        echo "Invalid database name. Must not contain spaces."
        return
    fi

    # Must start with a letter
    first_char="${db_name:0:1}"
    if [[ ! "$first_char" =~ [a-zA-Z] ]]; then
        echo "Invalid database name. Must start with a letter."
        return
    fi

    # Check if database exists
    if [ -d "$DB_PATH/$db_name" ]; then
        echo "Connecting to database '$db_name'..."
        cd "$DB_PATH/$db_name" || exit
        connected_db_menu "$db_name"
        echo "Return to main directory...."
        cd - || exit
    else
        echo "Database '$db_name' does not exist."
    fi
}



# Run the connect function
 connect_to_database


 
