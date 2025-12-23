#!/bin/bash

list_tables() {
    echo -e "\nList Tables\n"
    
    # Find all files ending with .table
    tables=(*.table)
    
    if [ ${#tables[@]} -eq 0  ]; then
         echo "No tables found in this database."
    else 
        echo -e "\nYour tables are:\n"
        for t in ${tables[@]} ; do
            echo "${t%.table}"
        done
    fi
    
}
