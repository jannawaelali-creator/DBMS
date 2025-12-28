#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

delete_fromtable() {

    echo -e "\n${CYAN}=== Delete From Table ===${NC}\n"

    # ---------- List tables ----------
    shopt -s nullglob
    tables=(*.table)
    if [ ${#tables[@]} -eq 0 ]; then
        echo -e "${RED}No tables found in this database.${NC}"
        shopt -u nullglob
        return
    fi

    echo -e "${CYAN}Available tables:${NC}"
    PS3="Choose a table: "
    select t in "${tables[@]}"; do
        if [ -n "$t" ]; then
            table_name="$t"
            break
        else
            echo -e "${RED}Invalid choice!${NC}"
        fi
    done
    shopt -u nullglob

    meta_file="metaData_${table_name%.table}"
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

    if [ -z "$primary_key" ]; then
        echo -e "${RED}Primary key not found in metadata!${NC}"
        return
    fi

    while true; do
        echo -e "\n1) By PRIMARY KEY"
        echo "2) Filter by column value"
        echo "3) Multiple conditions (AND)"
        echo "4) Back"
        read -r -p "Choice: " del_choice

        case $del_choice in
        1)
            # Delete by PRIMARY KEY
            read -r -p "Enter PRIMARY KEY ($primary_key, ${col_types[0]}): " pk_val
            pk_val=$(echo "$pk_val" | xargs)
            if [ -z "$pk_val" ]; then
                echo -e "${RED}Primary key cannot be empty!${NC}"
                continue
            fi
            if [ "${col_types[0]}" == "int" ] && ! [[ "$pk_val" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Primary key must be an integer!${NC}"
                continue
            fi

            matched=$(awk -F'|' -v pk="$pk_val" 'NR>2 {val=$2; gsub(/^[ \t]+|[ \t]+$/, "", val); if(val==pk) print}' "$table_name")
            if [ -z "$matched" ]; then
                echo -e "${RED}No record found with $primary_key = $pk_val${NC}"
                continue
            fi

            read -r -p "$(echo -e "${RED}Are you sure you want to delete this row? [y/n]: ${NC}")" confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo -e "${RED}Delete operation canceled.${NC}"
                continue
            fi

            awk -F'|' -v pk="$pk_val" 'NR<=2{print} NR>2 {val=$2; gsub(/^[ \t]+|[ \t]+$/, "", val); if(val!=pk) print}' "$table_name" > tmp && mv tmp "$table_name"
            echo -e "${GREEN}Row with PRIMARY KEY '$pk_val' deleted successfully!${NC}"
            ;;
        2)
            # Delete by single column value
            echo "Columns: ${col_names[*]}"
            read -r -p "Column: " col
            read -r -p "Value: " val
            col=$(echo "$col" | xargs)
            val=$(echo "$val" | xargs)

            col_index=-1
            for idx in "${!col_names[@]}"; do
                if [ "${col_names[idx]}" == "$col" ]; then
                    col_index=$((idx+2))
                fi
            done
            if [ $col_index -eq -1 ]; then
                echo -e "${RED}Column not found!${NC}"
                continue
            fi

            matched=$(awk -F'|' -v c=$col_index -v v="$val" 'NR>2 {field=$c; gsub(/^[ \t]+|[ \t]+$/, "", field); if(field==v) print}' "$table_name")
            if [ -z "$matched" ]; then
                echo -e "${RED}No records found for $col = $val${NC}"
                continue
            fi

            read -r -p "$(echo -e "${RED}Are you sure you want to delete these rows? [y/n]: ${NC}")" confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo -e "${RED}Delete operation canceled.${NC}"
                continue
            fi

            awk -F'|' -v c=$col_index -v v="$val" 'NR<=2{print} NR>2 {field=$c; gsub(/^[ \t]+|[ \t]+$/, "", field); if(field!=v) print}' "$table_name" > tmp && mv tmp "$table_name"
            echo -e "${GREEN}Rows with $col = '$val' deleted successfully!${NC}"
            ;;
        3)
            # Delete by multiple conditions (AND)
            echo "Columns: ${col_names[*]}"
            read -r -p "First column: " col1
            read -r -p "Value: " val1
            read -r -p "Second column: " col2
            read -r -p "Value: " val2

            col1=$(echo "$col1" | xargs)
            col2=$(echo "$col2" | xargs)
            val1=$(echo "$val1" | xargs)
            val2=$(echo "$val2" | xargs)

            idx1=-1
            idx2=-1
            for idx in "${!col_names[@]}"; do
                [ "${col_names[idx]}" == "$col1" ] && idx1=$((idx+2))
                [ "${col_names[idx]}" == "$col2" ] && idx2=$((idx+2))
            done

            if [ $idx1 -eq -1 ] || [ $idx2 -eq -1 ]; then
                echo -e "${RED}Column(s) not found!${NC}"
                continue
            fi

            matched=$(awk -F'|' -v c1=$idx1 -v v1="$val1" -v c2=$idx2 -v v2="$val2" 'NR>2 {f1=$c1; f2=$c2; gsub(/^[ \t]+|[ \t]+$/, "", f1); gsub(/^[ \t]+|[ \t]+$/, "", f2); if(f1==v1 && f2==v2) print}' "$table_name")
            if [ -z "$matched" ]; then
                echo -e "${RED}No records found matching both conditions.${NC}"
                continue
            fi

            read -r -p "$(echo -e "${RED}Are you sure you want to delete these rows? [y/n]: ${NC}")" confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo -e "${RED}Delete operation canceled.${NC}"
                continue
            fi

            awk -F'|' -v c1=$idx1 -v v1="$val1" -v c2=$idx2 -v v2="$val2" 'NR<=2{print} NR>2 {f1=$c1; f2=$c2; gsub(/^[ \t]+|[ \t]+$/, "", f1); gsub(/^[ \t]+|[ \t]+$/, "", f2); if(!(f1==v1 && f2==v2)) print}' "$table_name" > tmp && mv tmp "$table_name"
            echo -e "${GREEN}Rows matching both conditions deleted successfully!${NC}"
            ;;
        4)
            echo -e "${GREEN}Returning...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            ;;
        esac
    done
}

