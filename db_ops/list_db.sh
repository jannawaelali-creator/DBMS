#!/bin/bash

DB_DIR="./databases"

mkdir -p "$DB_DIR"

list_databases() {

    if [ "$(ls "$DB_DIR")" ]
    then
            echo "Available Databases:"
            echo "--------------------"
            ls "$DB_DIR"
    else echo "No databases found."
    fi
}



