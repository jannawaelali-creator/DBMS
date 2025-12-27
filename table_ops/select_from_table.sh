#!/bin/bash

select_table() {
    echo -e "\n=== Select From Table ===\n"

    # List available tables
    tables=(*.table)
    if [ ${#tables[@]} -eq 0 ]; then
        echo "No tables found in this database."
        return
    fi

    echo "Available tables:"
    PS3="Choose a table: "
    select t in "${tables[@]}"; do
        if [ -n "$t" ]; then
            table_name="$t"
            break
        else
            echo "Invalid choice!"
        fi
    done

    meta_file="metaData_${table_name%.table}"
    if [ ! -f "$meta_file" ]; then
        echo "Metadata not found!"
        return
    fi

    # Read metadata
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

    while true; do
        echo -e "\n1) List all rows"
        echo "2) Select specific rows"
        echo "3) Select specific columns"
        echo "4) Exit"
        read -r -p "Choice: " choice

        case $choice in
        1)
            if [ $(wc -l < "$table_name") -le 2 ]; then
                echo "No records found."
            else
                cat "$table_name"
            fi
            ;;
        2)
            echo -e "\n1) By PRIMARY KEY"
            echo "2) Filter by column value"
            echo "3) Multiple conditions (AND)"
            echo "4) Back"
            read -r -p "Choice: " row_choice

            case $row_choice in
            1)
                # PK validation loop
                while true; do
                    read -r -p "Enter PRIMARY KEY ($primary_key, ${col_types[0]}): " pk_val
                    pk_val=$(echo "$pk_val" | xargs)  # trim spaces
                    if [ -z "$pk_val" ]; then
                        echo "Primary key cannot be empty!"
                        continue
                    fi

                    if [ "${col_types[0]}" == "int" ]; then
                        if ! [[ "$pk_val" =~ ^-?[0-9]+$ ]]; then
                            echo "Primary key must be an integer!"
                            continue
                        elif [ "$pk_val" -le 0 ]; then
                            echo "Primary key must be positive!"
                            continue
                        fi
                    fi

                    # Check if PK exists
                    matched=$(awk -F'|' -v pk="$pk_val" 'NR>2 {val=$2; gsub(/^[ \t]+|[ \t]+$/, "", val); if(val==pk) print}' "$table_name")
                    if [ -z "$matched" ]; then
                        echo "No record found with $primary_key = $pk_val"
                        break
                    fi

                    awk -F'|' -v pk="$pk_val" 'NR<=2{print} NR>2 {val=$2; gsub(/^[ \t]+|[ \t]+$/, "", val); if(val==pk) print}' "$table_name"
                    break
                done
                ;;
            2)
                # Column filter validation
                while true; do
                    echo "Columns: ${col_names[*]}"
                    read -r -p "Column: " col
                    read -r -p "Value: " val
                    col=$(echo "$col" | xargs)
                    val=$(echo "$val" | xargs)

                    if [ -z "$col" ] || [ -z "$val" ]; then
                        echo "Column and value cannot be empty!"
                        continue
                    fi

                    col_index=-1
                    for idx in "${!col_names[@]}"; do
                        if [ "${col_names[idx]}" == "$col" ]; then
                            col_index=$((idx+2))
                        fi
                    done
                    if [ $col_index -eq -1 ]; then
                        echo "Column not found!"
                        continue
                    fi

                    matched=$(awk -F'|' -v c=$col_index -v v="$val" 'NR>2 {field=$c; gsub(/^[ \t]+|[ \t]+$/, "", field); if(field==v) print}' "$table_name")
                    if [ -z "$matched" ]; then
                        echo "No matched records found for $col = $val"
                    else
                        awk -F'|' -v c=$col_index -v v="$val" 'NR<=2{print} NR>2 {field=$c; gsub(/^[ \t]+|[ \t]+$/, "", field); if(field==v) print}' "$table_name"
                    fi
                    break
                done
                ;;
            3)
                while true; do
                    echo "Columns: ${col_names[*]}"
                    read -r -p "First column: " col1
                    read -r -p "Value: " val1
                    read -r -p "Second column: " col2
                    read -r -p "Value: " val2

                    col1=$(echo "$col1" | xargs)
                    col2=$(echo "$col2" | xargs)
                    val1=$(echo "$val1" | xargs)
                    val2=$(echo "$val2" | xargs)

                    if [ -z "$col1" ] || [ -z "$col2" ] || [ -z "$val1" ] || [ -z "$val2" ]; then
                        echo "Columns and values cannot be empty!"
                        continue
                    fi

                    idx1=-1
                    idx2=-1
                    for idx in "${!col_names[@]}"; do
                        [ "${col_names[idx]}" == "$col1" ] && idx1=$((idx+2))
                        [ "${col_names[idx]}" == "$col2" ] && idx2=$((idx+2))
                    done

                    if [ $idx1 -eq -1 ] || [ $idx2 -eq -1 ]; then
                        echo "Column not found!"
                        continue
                    fi

                    matched=$(awk -F'|' -v c1=$idx1 -v v1="$val1" -v c2=$idx2 -v v2="$val2" 'NR>2 {f1=$c1; f2=$c2; gsub(/^[ \t]+|[ \t]+$/, "", f1); gsub(/^[ \t]+|[ \t]+$/, "", f2); if(f1==v1 && f2==v2) print}' "$table_name")
                    if [ -z "$matched" ]; then
                        echo "No matched records found for $col1 = $val1 AND $col2 = $val2"
                    else
                        awk -F'|' -v c1=$idx1 -v v1="$val1" -v c2=$idx2 -v v2="$val2" 'NR<=2{print} NR>2 {f1=$c1; f2=$c2; gsub(/^[ \t]+|[ \t]+$/, "", f1); gsub(/^[ \t]+|[ \t]+$/, "", f2); if(f1==v1 && f2==v2) print}' "$table_name"
                    fi
                    break
                done
                ;;
            4)
                continue
                ;;
            *)
                echo "Invalid choice!"
                ;;
            esac
            ;;
        3)
            echo -e "\n1) One column"
            echo "2) Multiple columns"
            echo "3) Back"
            read -r -p "Choice: " col_choice

            case $col_choice in
            1)
                while true; do
                    echo "Columns: ${col_names[*]}"
                    read -r -p "Column: " col
                    col=$(echo "$col" | xargs)
                    if [ -z "$col" ]; then
                        echo "Column cannot be empty!"
                        continue
                    fi

                    col_index=-1
                    for idx in "${!col_names[@]}"; do
                        if [ "${col_names[idx]}" == "$col" ]; then
                            col_index=$((idx+2))
                        fi
                    done

                    if [ $col_index -eq -1 ]; then
                        echo "Column not found!"
                        continue
                    fi

                    awk -F'|' -v c=$col_index '
                    NR==1 {header=$c; next}
                    NR>2 {rows[NR]=$c; gsub(/^[ \t]+|[ \t]+$/, "", rows[NR])}
                    END {
                        maxlen=length(header)
                        for(i in rows){ if(length(rows[i])>maxlen) maxlen=length(rows[i]) }
                        printf "| %-*s |\n", maxlen, header
                        printf "|"; for(i=1;i<=maxlen+2;i++) printf "-"; print "|"
                        for(i=3;i<=NR;i++) printf "| %-*s |\n", maxlen, rows[i]
                    }
                    ' "$table_name"
                    break
                done
                ;;
            2)
                while true; do
                    echo "Columns: ${col_names[*]}"
                    read -r -p "Enter columns (space separated): " cols
                    cols=$(echo "$cols" | xargs)
                    if [ -z "$cols" ]; then
                        echo "Columns cannot be empty!"
                        continue
                    fi

                    col_indices=()
                    for c in $cols; do
                        found=-1
                        for idx in "${!col_names[@]}"; do
                            if [ "${col_names[idx]}" == "$c" ]; then
                                found=$((idx+2))
                            fi
                        done
                        if [ $found -eq -1 ]; then
                            echo "Column $c not found!"
                            continue 2
                        fi
                        col_indices+=($found)
                    done

                    awk -F'|' -v cols="${col_indices[*]}" -v names="$cols" '
                    BEGIN { split(cols,c," "); split(names,n," ") }
                    NR>2 {
                        row_num=NR-2
                        for(i=1;i<=length(c);i++){
                            field=$(c[i])
                            gsub(/^[ \t]+|[ \t]+$/, "", field)
                            if(length(field)>w[i]) w[i]=length(field)
                            data[row_num,i]=field
                        }
                    }
                    END {
                        for(i=1;i<=length(n);i++) if(length(n[i])>w[i]) w[i]=length(n[i])
                        # header
                        printf "|"
                        for(i=1;i<=length(n);i++) printf " %-*s |", w[i], n[i]
                        print ""
                        # separator
                        printf "|"
                        for(i=1;i<=length(n);i++){ for(j=1;j<=w[i]+2;j++) printf "-"; printf "|" }
                        print ""
                        # values
                        for(r=1;r<=NR-2;r++){
                            printf "|"
                            for(i=1;i<=length(c);i++){
                                printf " %-*s |", w[i], data[r,i]
                            }
                            print ""
                        }
                    }
                    ' "$table_name"
                    break
                done
                ;;
            3)
                continue
                ;;
            *)
                echo "Invalid choice!"
                ;;
            esac
            ;;
        4)
            echo "Returning..."
            break
            ;;
        *)
            echo "Invalid choice!"
            ;;
        esac
    done
}

