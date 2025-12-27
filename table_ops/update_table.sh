#!/bin/bash

update_table() {
    echo -e "\n=== Update Table ===\n"

    # ---------- List tables ----------
    tables=(*.table)
    if [ ${#tables[@]} -eq 0 ]; then
        echo "No tables found."
        return
    fi

    echo "Select table:"
    PS3="Choose: "
    select t in "${tables[@]}"; do
        if [[ -n "$t" ]]; then
            table_name="${t%.table}"
            break
        else
            echo "Invalid choice!"
        fi
    done

    meta_file="metaData_$table_name"
    if [ ! -f "$meta_file" ]; then
        echo "Metadata not found!"
        return
    fi

    # ---------- Read metadata ----------
    col_names=()
    col_types=()
    primary_key=""
    i=0
    while read line; do
        # Skip first 2 lines (Table Name, Columns)
        if [ $i -lt 2 ]; then
            i=$((i+1))
            continue
        fi
        key=$(echo "$line" | cut -d: -f1)
        name=$(echo "$line" | cut -d: -f2)
        type=$(echo "$line" | cut -d: -f3)
        col_names+=("$name")
        col_types+=("$type")
        if [ "$key" == "primary_key" ]; then
            primary_key="$name"
        fi
    done < "$meta_file"

    # ---------- Ask for PK ----------
while true; do
    read -r -p "Enter PRIMARY KEY ($primary_key, ${col_types[0]}): " pk_value
    pk_value=$(echo "$pk_value" | xargs)
    if [ -z "$pk_value" ]; then
        echo "Primary key cannot be empty!"
        continue
    fi

    if [ "${col_types[0]}" == "int" ]; then
        if ! [[ "$pk_value" =~ ^-?[0-9]+$ ]]; then
            echo "Primary key must be an integer!"
            continue
        elif [ "$pk_value" -lt 0 ]; then
            echo "Primary key cannot be negative!"
            continue
        elif [ "$pk_value" -eq 0 ]; then
            echo "Primary key cannot be zero!"
            continue
        fi
    fi

    if [ "${col_types[0]}" == "str" ] && [ -z "$pk_value" ]; then
        echo "Primary key cannot be empty!"
        continue
    fi

    break
done
    # ---------- Find row ----------
    row_num=$(awk -F'|' -v pk="$pk_value" 'NR>2 {gsub(/^[ \t]+|[ \t]+$/, "", $2); if($2==pk){print NR; exit}}' "$table_name.table")
    if [ -z "$row_num" ]; then
        echo "Record not found!"
        return
    fi

    # ---------- Load row values ----------
    values=()
    line=$(sed -n "${row_num}p" "$table_name.table")
    # Split by | and trim spaces
    IFS='|' read -ra temp <<< "$line"
    for ((j=1; j<${#temp[@]}; j++)); do
        values+=("$(echo "${temp[j]}" | xargs)")
    done

    # ---------- Update loop ----------
    while true; do
        echo -e "\nWhich column to update?"
        for idx in "${!col_names[@]}"; do
            echo "$((idx+1))) ${col_names[idx]}"
        done
        echo "$(( ${#col_names[@]} + 1 ))) Exit"

        read -r -p "Choice: " choice

	if [[ -z "$choice" || "$choice" == *" "* ]]; then
		echo "Invalid choice! can't be empty"
		continue
	fi

	if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
   		 echo "Invalid choice! Please enter a number."
    		 continue
	fi

        if [ "$choice" -eq $(( ${#col_names[@]} + 1 )) ]; then
	    echo "Invalid choice!"
            break
        fi

        index=$((choice-1))
        if [ $index -lt 0 ] || [ $index -ge ${#col_names[@]} ]; then
            echo "Invalid choice!"
            continue
        fi

        echo "Old value: ${values[index]}"

        # ---------- New value ----------
        while true; do
            read -r -p "Enter new value (${col_types[index]}): " new_val
  	    new_val=$(echo "$new_val" | xargs)

            # PK rules
            if [ "${col_names[index]}" == "$primary_key" ]; then
                if [ -z "$new_val" ]; then
                    echo "Primary key cannot be empty!"
                    continue
                fi

		if ["${col_types[index]}" == "int" ]; then
			if ! [[ "$new_val" =~ ^-?[0-9]+$ ]]; then
				echo "Primary key must be an integer!"
				continue;
			elif [ "$new_val" -lt 0 ]; then
				echo "Primary key cannot be negative!"
				continue
			elif [ "$new_val" -eq 0 ]; then
				echo "Primary key cannot be zero!"
				continue
			fi
		elif [ "${col_types[index]}" == "str" ] && [ -z "$new_val" ]; then
			echo "Primary key cannot be empty!"
			continue
		fi

                # Check uniqueness
                exists=$(awk -F'|' -v pk="$new_val" -v line="$row_num" 'NR>2 && NR!=line {gsub(/^[ \t]+|[ \t]+$/, "", $2); if($2==pk){print 1; exit}}' "$table_name.table")
                if [ "$exists" == "1" ]; then
                    echo "Primary key already exists!"
                    continue
                fi
            fi

            # Type check
            if [ "${col_types[index]}" == "int" ] && ! [[ "$new_val" =~ ^[0-9]+$ ]]; then
                echo "Invalid integer!"
                continue
            elif [ "${col_types[index]}" == "str" ] && [ -z "$new_val" ]; then
                echo "String cannot be empty!"
                continue
	    elif [ "${col_types[index]}" == "str" ] && [[ "$new_val" == *"|"* ]]; then
		echo "Invalid input! Column values cannot contain '|'"
		continue
	    fi

            break
        done

        # Apply update
        values[index]="$new_val"

        # ---------- Build row ----------
        new_row="|"
        for v in "${values[@]}"; do
            new_row="$new_row $(printf '%-20s' "$v") |"
        done

        # ---------- Save updated row ----------
        awk -v line="$row_num" -v new="$new_row" 'NR==line {print new; next} {print}' "$table_name.table" > tmp && mv tmp "$table_name.table"

        echo "Column updated successfully!"
    done

    echo -e "\nUpdate operation completed.\n"
}

