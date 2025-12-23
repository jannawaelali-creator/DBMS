#!/bin/bash

DB_DIR="./databases"
# Ensure databases folder exists
mkdir -p "$DB_DIR"


 drop_database(){
	 echo "Available databases"
	 ls $DB_DIR

read -p "Enter database name to drop: " db_name

  db_name=$(echo "$db_name" | xargs)  # trim spaces

        # Check if empty
        if [[ -z "$db_name" ]]; then
            echo "Invalid database name. Must not be empty."
            return
        fi

        # Check for spaces
        if [[ "$db_name" == *" "* ]]; then
            echo "Invalid database name. Must not contain spaces."
            return
        fi

        # Check if starts with a letter
        if [[ ! "$db_name" =~ ^[a-zA-Z] ]]; then
            echo "Invalid database name. Must start with a letter."
            return
        fi



   if [ -d "$DB_DIR/$db_name" ]
     then
      while true; do
        read -r -p "Are you sure you want to delete database '$db_name'? [y/n]: " confirm
        case "$confirm" in
            [Yy])
                rm -r "$DB_DIR/$db_name"
                echo "Database '$db_name' has been deleted."
                break
                ;;
            [Nn])
                echo "Operation cancelled."
                break
                ;;
            *)
                echo "Invalid input. Please enter 'y' for yes or 'n' for no."
                ;;
        esac
    done
else
    echo "Database '$db_name' does not exist."
fi

}

drop_database
