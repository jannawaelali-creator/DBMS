#!/bin/bash

DB_DIR="./databases"
# Ensure databases folder exists
mkdir -p "$DB_DIR"


 drop_database(){
read -p "Enter database name to drop: " db_name
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
