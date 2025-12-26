#!/bin/bash

drop_table() {
    echo -e "\n=== Drop Table ===\n"

    # List available tables
    tables=(*.table "Exit")
    if [ ${#tables[@]} -eq 0 ]; then
        echo "No tables found in this database."
        return
    fi


    # Let user select table to drop
    PS3="Enter the number of the table to drop: "
    select t in "${tables[@]}"; do
	if [[ "$t" == "Exit" ]]; then
	    echo "Cancelled table deletion."
	    return
        elif [[ -n "$t" ]]; then
            table_name="${t%.table}"
            break
        else
            echo "Invalid choice, try again."
        fi
    done

    # Confirm deletion
    while true; do
        read -r -p "Are you sure you want to delete table '$table_name'? [y/n]: " confirm
        case "$confirm" in
            [Yy])
                rm -f "$table_name.table" "metaData_$table_name"
                echo "Table '$table_name' has been deleted successfully."
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
}

