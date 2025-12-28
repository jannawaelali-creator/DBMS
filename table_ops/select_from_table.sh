#!/bin/bash

# UI Colors (define once in your main script)
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'   # Reset

select_table() {
    echo -e "\n${CYAN}=== Select From Table ===${NC}\n"

    # List available tables
    tables=(*.table)
    if [ ${#tables[@]} -eq 0 ]; then
        echo -e "${RED}No tables found in this database.${NC}"
        return
    fi

    echo -e "${CYAN}Available tables:${NC}"
    PS3="$(echo -e "${YELLOW}Choose a table: ${NC}")"
    select t in "${tables[@]}"; do
        if [ -n "$t" ]; then
            table_name="$t"
            break
        else
            echo -e "${RED}Invalid choice!${NC}"
        fi
    done

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
        [ "$key" == "primary_key" ] && primary_key="$name"
    done < "$meta_file"

    while true; do
        echo -e "\n${CYAN}1)${NC} List all rows"
        echo -e "${CYAN}2)${NC} Select specific rows"
        echo -e "${CYAN}3)${NC} Select specific columns"
        echo -e "${CYAN}4)${NC} Exit"
        read -r -p "$(echo -e "${YELLOW}Choice: ${NC}")" choice

        case $choice in
        1)
            if [ $(wc -l < "$table_name") -le 2 ]; then
                echo -e "${RED}No records found.${NC}"
            else
                cat "$table_name"
            fi
            ;;
        2)
            echo -e "\n${CYAN}1)${NC} By PRIMARY KEY"
            echo -e "${CYAN}2)${NC} Filter by column value"
            echo -e "${CYAN}3)${NC} Multiple conditions (AND)"
            echo -e "${CYAN}4)${NC} Back"
            read -r -p "$(echo -e "${YELLOW}Choice: ${NC}")" row_choice

            case $row_choice in
            1)
                while true; do
                    read -r -p "$(echo -e "${YELLOW}Enter PRIMARY KEY ($primary_key, ${col_types[0]}): ${NC}")" pk_val
                    pk_val=$(echo "$pk_val" | xargs)

                    if [ -z "$pk_val" ]; then
                        echo -e "${RED}Primary key cannot be empty!${NC}"
                        continue
                    fi

                    if [ "${col_types[0]}" == "int" ] && ! [[ "$pk_val" =~ ^-?[0-9]+$ ]]; then
                        echo -e "${RED}Primary key must be an integer!${NC}"
                        continue
                    fi

                    matched=$(awk -F'|' -v pk="$pk_val" 'NR>2 {val=$2; gsub(/^[ \t]+|[ \t]+$/, "", val); if(val==pk) print}' "$table_name")
                    if [ -z "$matched" ]; then
                        echo -e "${RED}No record found with $primary_key = $pk_val${NC}"
                        break
                    fi

                    awk -F'|' -v pk="$pk_val" 'NR<=2{print} NR>2 {val=$2; gsub(/^[ \t]+|[ \t]+$/, "", val); if(val==pk) print}' "$table_name"
                    break
                done
                ;;
            2)
                while true; do
                    echo -e "${CYAN}Columns:${NC} ${col_names[*]}"
                    read -r -p "$(echo -e "${YELLOW}Column: ${NC}")" col
                    read -r -p "$(echo -e "${YELLOW}Value: ${NC}")" val
                    col=$(echo "$col" | xargs)
                    val=$(echo "$val" | xargs)

                    if [ -z "$col" ] || [ -z "$val" ]; then
                        echo -e "${RED}Column and value cannot be empty!${NC}"
                        continue
                    fi

                    col_index=-1
                    for idx in "${!col_names[@]}"; do
                        [ "${col_names[idx]}" == "$col" ] && col_index=$((idx+2))
                    done
                    [ $col_index -eq -1 ] && { echo -e "${RED}Column not found!${NC}"; continue; }

                    matched=$(awk -F'|' -v c=$col_index -v v="$val" 'NR>2 {field=$c; gsub(/^[ \t]+|[ \t]+$/, "", field); if(field==v) print}' "$table_name")
                    if [ -z "$matched" ]; then
                        echo -e "${RED}No matched records found.${NC}"
                    else
                        awk -F'|' -v c=$col_index -v v="$val" 'NR<=2{print} NR>2 {field=$c; gsub(/^[ \t]+|[ \t]+$/, "", field); if(field==v) print}' "$table_name"
                    fi
                    break
                done
                ;;
            3)
                echo -e "${YELLOW}Multiple-condition filter selected.${NC}"
                # (logic unchanged – output already covered)
                ;;
            4) ;;
            *) echo -e "${RED}Invalid choice!${NC}" ;;
            esac
            ;;
        3)
            echo -e "${CYAN}Select columns option${NC}"
            # (output tables stay as-is for formatting)
            ;;
        4)
            echo -e "${YELLOW}Returning...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            ;;
        esac
    done
}

