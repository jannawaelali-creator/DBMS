#!/bin/bash

DB_DIR="./databases"
mkdir -p "$DB_DIR"

create_database() {
    read -r -p "Enter database name: " db_name

    if [[ -z "$db_name" ]]
    then
            echo "Invalid database name."
            echo "Must not be empty."
            return
    fi

    if [[ "$db_name" == *" "* ]]
    then
            echo "Invalid database name."
            echo "Must not conatin spaces."
            return
    fi

    if [[ "$db_name" != [a-zA-Z]* ]]
    then
            echo "Invalid database name."
            echo "Must start with an alphabetic character."
            return
    fi

    if [ -d "$DB_DIR/$db_name" ];
    then
        echo "Database '$db_name' already exists."
    else
        mkdir "$DB_DIR/$db_name"
        echo "Database '$db_name' created successfully."
    fi
}


