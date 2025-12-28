#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'   # Reset

update_table() {
    echo -e "\n${CYAN}=== Update Table ===${NC}\n"

    # ---------- List tables ----------
    shopt -s nullglob
    tables=(*.table)
    if [ ${#tables[@]} -eq 0 ]; then
        echo -e "${RED}No tables found.${NC}"
        return
    fi

    shopt -u nullglob

    echo -e "${CYAN}Select table:${NC}"
    PS3="Choose: "
    select t in "${tables[@]}"; do
        if [[ -n "$t" ]]; then
            table_name="${t%.table}"
            break
        else
            echo -e "${RED}Invalid choice!${NC}"
        fi
    done

    meta_file="metaData_$table_name"
    if [ ! -f "$meta_file" ]; then
        echo -e "${RED}Metadata not found!${NC}"
        return
    fi

    # ---------- Read metadata ----------
    col_names=()
    col_types=()
    primary_key=""
    i=0
    while read line; do
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
            echo -e "${RED}Primary key cannot be empty!${NC}"
            continue
        fi

        if [ "${col_types[0]}" == "int" ]; then
            if ! [[ "$pk_value" =~ ^-?[0-9]+$ ]]; then
                echo -e "${RED}Primary key must be an integer!${NC}"
                continue
            elif [ "$pk_value" -lt 0 ]; then
                echo -e "${RED}Primary key cannot be negative!${NC}"
                continue
            elif [ "$pk_value" -eq 0 ]; then
                echo -e "${RED}Primary key cannot be zero!${NC}"
                continue
            fi
        fi
        break
    done

    # ---------- Find row ----------
    row_num=$(awk -F'|' -v pk="$pk_value" 'NR>2 {gsub(/^[ \t]+|[ \t]+$/, "", $2); if($2==pk){print NR; exit}}' "$table_name.table")
    if [ -z "$row_num" ]; then
        echo -e "${RED}Record not found!${NC}"
        return
    fi

    # ---------- Load row values ----------
    values=()
    line=$(sed -n "${row_num}p" "$table_name.table")
    IFS='|' read -ra temp <<< "$line"
    for ((j=1; j<${#temp[@]}; j++)); do
        values+=("$(echo "${temp[j]}" | xargs)")
    done

    # ---------- Update loop ----------
    while true; do
        echo -e "\n${CYAN}Which column to update?${NC}"
        for idx in "${!col_names[@]}"; do
            echo "$((idx+1))) ${col_names[idx]}"
        done
        echo "$(( ${#col_names[@]} + 1 ))) Exit"

        read -r -p "Choice: " choice

        if [[ -z "$choice" || "$choice" == *" "* ]]; then
            echo -e "${RED}Invalid choice! Can't be empty.${NC}"
            continue
        fi

        if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid choice! Please enter a number.${NC}"
            continue
        fi

        if [ "$choice" -eq $(( ${#col_names[@]} + 1 )) ]; then
            echo -e "${RED}Update cancelled.${NC}"
            break
        fi

        index=$((choice-1))
        if [ $index -lt 0 ] || [ $index -ge ${#col_names[@]} ]; then
            echo -e "${RED}Invalid choice!${NC}"
            continue
        fi

        echo -e "${CYAN}Old value:${NC} ${values[index]}"

        # ---------- New value ----------
        while true; do
            read -r -p "Enter new value (${col_types[index]}): " new_val
            new_val=$(echo "$new_val" | xargs)

            if [ "${col_names[index]}" == "$primary_key" ] && [ -z "$new_val" ]; then
                echo -e "${RED}Primary key cannot be empty!${NC}"
                continue
            fi

            if [ "${col_types[index]}" == "int" ] && ! [[ "$new_val" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid integer!${NC}"
                continue
            elif [ "${col_types[index]}" == "str" ] && [ -z "$new_val" ]; then
                echo -e "${RED}String cannot be empty!${NC}"
                continue
            elif [ "${col_types[index]}" == "str" ] && [[ "$new_val" == *"|"* ]]; then
                echo -e "${RED}Invalid input! Column values cannot contain '|'.${NC}"
                continue
            fi

            break
        done

        values[index]="$new_val"

        # ---------- Build row ----------
        new_row="|"
        for v in "${values[@]}"; do
            new_row="$new_row $(printf '%-20s' "$v") |"
        done

        # ---------- Save updated row ----------
        awk -v line="$row_num" -v new="$new_row" 'NR==line {print new; next} {print}' "$table_name.table" > tmp && mv tmp "$table_name.table"

        echo -e "${GREEN}Column updated successfully!${NC}"
    done

    echo -e "\n${GREEN}Update operation completed.${NC}\n"
}

