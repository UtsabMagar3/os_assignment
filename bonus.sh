#!/bin/bash
# Mercedes Benz Salesperson Bonus Calculator - Multi-Month Dialog Version
# Author: Auto-generated script
# Description: Calculates monthly salary and bonus for Mercedes Benz salespersons using dialog interface

# Standard dialog dimensions
DIALOG_HEIGHT=12
DIALOG_WIDTH=70
MENU_HEIGHT=8

declare -A car_prices=(
    ["A"]="31095"
    ["B"]="33162"
    ["C"]="42537"
    ["E"]="54437"
    ["AMG"]="79660"
)

# Month names mapping
declare -A month_names=(
    ["January"]="1"
    ["February"]="2"
    ["March"]="3"
    ["April"]="4"
    ["May"]="5"
    ["June"]="6"
    ["July"]="7"
    ["August"]="8"
    ["September"]="9"
    ["October"]="10"
    ["November"]="11"
    ["December"]="12"
)

BASIC_SALARY=2000
PERSONAL_ALLOWANCE=12500

declare -a selected_months
declare -a selected_month_names
declare -a names
declare -A total_sales_per_month
declare -A monthly_salaries_per_month
declare -A net_salaries_per_month
declare -A bonuses_per_month
declare -A taxes_per_month

num_months=""
num_salespersons=""

validate_name() {
    local name="$1"
    if [[ "$name" =~ ^[A-Za-z][A-Za-z\ ]{1,49}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_car_model() {
    local model="$1"
    case "$model" in
        A|B|C|E|AMG) return 0 ;;
        *) return 1 ;;
    esac
}

validate_quantity() {
    local qty="$1"
    if [[ "$qty" =~ ^[1-9][0-9]{0,2}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_file_path() {
    local path="$1"
    if [[ "$path" =~ ^[A-Za-z0-9._/-]+$ ]]; then
        local dir=$(dirname "$path")
        if [[ -d "$dir" || "$dir" == "." ]]; then
            return 0
        fi
    fi
    return 1
}

get_num_months() {
    while true; do
        num_months=$(dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Number of Months" \
            --inputbox "Enter number of months to process (1-12):" $DIALOG_HEIGHT $DIALOG_WIDTH 3>&1 1>&2 2>&3)
        local exit_status=$?
        if [ $exit_status -eq 0 ]; then
            if [[ "$num_months" =~ ^[0-9]+$ ]] && [ "$num_months" -ge 1 ] && [ "$num_months" -le 12 ]; then
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Success" \
                    --msgbox "Processing $num_months month(s)." $DIALOG_HEIGHT $DIALOG_WIDTH
                break
            else
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Error" \
                    --msgbox "Invalid input! Please enter a number between 1 and 12." $DIALOG_HEIGHT $DIALOG_WIDTH
            fi
        else
            dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Cancelled" \
                --msgbox "Operation cancelled by user." $DIALOG_HEIGHT $DIALOG_WIDTH
            clear
            exit 0
        fi
    done
}

get_months() {
    declare -a temp_months
    declare -a temp_month_names
    
    for ((i=0; i<num_months; i++)); do
        while true; do
            local month_name=$(dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Select Month $((i + 1))" \
                --menu "Choose month $((i + 1)):" $DIALOG_HEIGHT $DIALOG_WIDTH $MENU_HEIGHT \
                "January" "January" \
                "February" "February" \
                "March" "March" \
                "April" "April" \
                "May" "May" \
                "June" "June" \
                "July" "July" \
                "August" "August" \
                "September" "September" \
                "October" "October" \
                "November" "November" \
                "December" "December" 3>&1 1>&2 2>&3)
            
            if [ $? -eq 0 ]; then
                # Check if month already selected
                local already_selected=false
                for selected in "${temp_month_names[@]}"; do
                    if [ "$selected" = "$month_name" ]; then
                        already_selected=true
                        break
                    fi
                done
                
                if [ "$already_selected" = true ]; then
                    dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Error" \
                        --msgbox "Month $month_name already selected! Please choose a different month." $DIALOG_HEIGHT $DIALOG_WIDTH
                else
                    temp_months[i]=${month_names[$month_name]}
                    temp_month_names[i]=$month_name
                    dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Success" \
                        --msgbox "Month $month_name selected successfully!" $DIALOG_HEIGHT $DIALOG_WIDTH
                    break
                fi
            else
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Cancelled" \
                    --msgbox "Operation cancelled by user." $DIALOG_HEIGHT $DIALOG_WIDTH
                clear
                exit 0
            fi
        done
    done
    
    # Copy to global arrays
    selected_months=("${temp_months[@]}")
    selected_month_names=("${temp_month_names[@]}")
}

get_num_salespersons() {
    while true; do
        num_salespersons=$(dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Number of Salespersons" \
            --inputbox "Enter number of salespersons (3-20):" $DIALOG_HEIGHT $DIALOG_WIDTH 3>&1 1>&2 2>&3)
        local exit_status=$?
        if [ $exit_status -eq 0 ]; then
            if [[ "$num_salespersons" =~ ^[0-9]+$ ]] && [ "$num_salespersons" -ge 3 ] && [ "$num_salespersons" -le 20 ]; then
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Success" \
                    --msgbox "Processing $num_salespersons salespersons." $DIALOG_HEIGHT $DIALOG_WIDTH
                break
            else
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Error" \
                    --msgbox "Invalid input! Please enter a number between 3 and 20." $DIALOG_HEIGHT $DIALOG_WIDTH
            fi
        else
            dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Cancelled" \
                --msgbox "Operation cancelled by user." $DIALOG_HEIGHT $DIALOG_WIDTH
            clear
            exit 0
        fi
    done
}

get_salesperson_names() {
    for ((i=0; i<num_salespersons; i++)); do
        while true; do
            local name=$(dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Salesperson $((i + 1))" \
                --inputbox "Enter salesperson name:" $DIALOG_HEIGHT $DIALOG_WIDTH 3>&1 1>&2 2>&3)
            local exit_status=$?
            if [ $exit_status -eq 0 ]; then
                if validate_name "$name"; then
                    names[i]="$name"
                    break
                else
                    dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Error" \
                        --msgbox "Invalid name! Must start with a letter and contain only letters and spaces (2-50 chars)." $DIALOG_HEIGHT $DIALOG_WIDTH
                fi
            else
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Cancelled" \
                    --msgbox "Operation cancelled by user." $DIALOG_HEIGHT $DIALOG_WIDTH
                clear
                exit 0
            fi
        done
    done
}

get_salesperson_data_for_month() {
    local month_name=$1
    local month_num=$2
    local person_index=$3
    local person_name="${names[person_index]}"
    
    local sales_total=0
    local sales_details=""
    
    while true; do
        local current_info="Month: $month_name\nSalesperson: $person_name\n\nCurrent total: £$sales_total\n\nSales details:\n$sales_details"
        dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Car Sales Data Entry" \
            --yesno "$current_info\n\nDo you want to add more car sales?" $DIALOG_HEIGHT $DIALOG_WIDTH
        local choice=$?
        
        if [ $choice -eq 0 ]; then
            local model=$(dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Select Car Model" \
                --menu "Choose a car model:" $DIALOG_HEIGHT $DIALOG_WIDTH $MENU_HEIGHT \
                A "A Class - £31,095" \
                B "B Class - £33,162" \
                C "C Class - £42,537" \
                E "E Class - £54,437" \
                AMG "AMG C65 - £79,660" 3>&1 1>&2 2>&3)
            if [ $? -ne 0 ]; then
                continue
            fi
            
            while true; do
                local quantity=$(dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Quantity" \
                    --inputbox "Enter quantity sold for model $model:" $DIALOG_HEIGHT $DIALOG_WIDTH 3>&1 1>&2 2>&3)
                if [ $? -eq 0 ]; then
                    if validate_quantity "$quantity"; then
                        local car_value=$((${car_prices[$model]} * quantity))
                        sales_total=$((sales_total + car_value))
                        sales_details="$sales_details$quantity x $model = £$car_value\n"
                        
                        dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Added" \
                            --msgbox "Added: $quantity x $model (£${car_prices[$model]} each) = £$car_value\nNew total: £$sales_total" $DIALOG_HEIGHT $DIALOG_WIDTH
                        break
                    else
                        dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Error" \
                            --msgbox "Invalid quantity! Please enter a number between 1 and 999." $DIALOG_HEIGHT $DIALOG_WIDTH
                    fi
                else
                    break
                fi
            done
        else
            if [ $sales_total -eq 0 ]; then
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Error" \
                    --msgbox "Must enter at least one car sale!" $DIALOG_HEIGHT $DIALOG_WIDTH
            else
                break
            fi
        fi
    done
    
    total_sales_per_month["${person_index}_${month_num}"]=$sales_total
    dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Complete" \
        --msgbox "Total sales for $person_name in $month_name: £$sales_total" $DIALOG_HEIGHT $DIALOG_WIDTH
}

calculate_bonus() {
    local sales=$1
    
    if [ $sales -ge 650000 ]; then
        echo 30000
    elif [ $sales -ge 500000 ]; then
        echo 25000
    elif [ $sales -ge 400000 ]; then
        echo 20000
    elif [ $sales -ge 300000 ]; then
        echo 15000
    elif [ $sales -ge 200000 ]; then
        echo 10000
    else
        echo 0
    fi
}

calculate_tax() {
    local annual_salary=$1
    local tax=0
    
    if [ $annual_salary -le $PERSONAL_ALLOWANCE ]; then
        tax=0
    elif [ $annual_salary -le 50000 ]; then
        tax=$(( (annual_salary - PERSONAL_ALLOWANCE) * 20 / 100 ))
    elif [ $annual_salary -le 150000 ]; then
        local basic_tax=$(( (50000 - PERSONAL_ALLOWANCE) * 20 / 100 ))
        local higher_tax=$(( (annual_salary - 50000) * 40 / 100 ))
        tax=$((basic_tax + higher_tax))
    else
        local basic_tax=$(( (50000 - PERSONAL_ALLOWANCE) * 20 / 100 ))
        local higher_tax=$(( (150000 - 50000) * 40 / 100 ))
        local additional_tax=$(( (annual_salary - 150000) * 45 / 100 ))
        tax=$((basic_tax + higher_tax + additional_tax))
    fi
    
    echo $tax
}

process_all_data() {
    for ((m=0; m<num_months; m++)); do
        local month_num=${selected_months[m]}
        for ((i=0; i<num_salespersons; i++)); do
            local sales=${total_sales_per_month["${i}_${month_num}"]}
            local bonus=$(calculate_bonus $sales)
            local monthly_salary=$((BASIC_SALARY + bonus))
            local annual_salary=$((monthly_salary * 12))
            local annual_tax=$(calculate_tax $annual_salary)
            local monthly_tax=$((annual_tax / 12))
            local net_monthly_salary=$((monthly_salary - monthly_tax))
            
            bonuses_per_month["${i}_${month_num}"]=$bonus
            monthly_salaries_per_month["${i}_${month_num}"]=$monthly_salary
            taxes_per_month["${i}_${month_num}"]=$monthly_tax
            net_salaries_per_month["${i}_${month_num}"]=$net_monthly_salary
        done
    done
}

bubble_sort_names() {
    local n=$num_salespersons
    
    for ((i=0; i<n-1; i++)); do
        for ((j=0; j<n-i-1; j++)); do
            if [[ "${names[j]}" > "${names[j+1]}" ]]; then
                swap_person_data $j $((j+1))
            fi
        done
    done
}

bubble_sort_gross_salary() {
    local n=$num_salespersons
    local sort_month=${selected_months[0]}  # Use first selected month for sorting
    
    for ((i=0; i<n-1; i++)); do
        for ((j=0; j<n-i-1; j++)); do
            local salary_j=${monthly_salaries_per_month["${j}_${sort_month}"]}
            local salary_j1=${monthly_salaries_per_month["$((j+1))_${sort_month}"]}
            
            # Sort in descending order (highest salary first)
            if [ $salary_j -lt $salary_j1 ]; then
                swap_person_data $j $((j+1))
            fi
        done
    done
}

swap_person_data() {
    local idx1=$1
    local idx2=$2
    
    # Swap names
    local temp_name="${names[idx1]}"
    names[idx1]="${names[idx2]}"
    names[idx2]="$temp_name"
    
    # Swap all associated data for all months
    for ((m=0; m<num_months; m++)); do
        local month_num=${selected_months[m]}
        
        local temp_sales=${total_sales_per_month["${idx1}_${month_num}"]}
        total_sales_per_month["${idx1}_${month_num}"]=${total_sales_per_month["${idx2}_${month_num}"]}
        total_sales_per_month["${idx2}_${month_num}"]=$temp_sales
        
        local temp_salary=${monthly_salaries_per_month["${idx1}_${month_num}"]}
        monthly_salaries_per_month["${idx1}_${month_num}"]=${monthly_salaries_per_month["${idx2}_${month_num}"]}
        monthly_salaries_per_month["${idx2}_${month_num}"]=$temp_salary
        
        local temp_net=${net_salaries_per_month["${idx1}_${month_num}"]}
        net_salaries_per_month["${idx1}_${month_num}"]=${net_salaries_per_month["${idx2}_${month_num}"]}
        net_salaries_per_month["${idx2}_${month_num}"]=$temp_net
        
        local temp_bonus=${bonuses_per_month["${idx1}_${month_num}"]}
        bonuses_per_month["${idx1}_${month_num}"]=${bonuses_per_month["${idx2}_${month_num}"]}
        bonuses_per_month["${idx2}_${month_num}"]=$temp_bonus
        
        local temp_tax=${taxes_per_month["${idx1}_${month_num}"]}
        taxes_per_month["${idx1}_${month_num}"]=${taxes_per_month["${idx2}_${month_num}"]}
        taxes_per_month["${idx2}_${month_num}"]=$temp_tax
    done
}

get_sort_preference() {
    local sort_choice=$(dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Select Report Sorting" \
        --menu "How would you like to sort the report?" $DIALOG_HEIGHT $DIALOG_WIDTH $MENU_HEIGHT \
        "ALPHABETICAL" "Name Order (A-Z)" \
        "GROSS_SALARY" "Salary (Gross Salary - Highest First)" \
        "NET_SALARY" "Name with Associated Net Salary (Net Salary - Highest First)" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        case $sort_choice in
            "ALPHABETICAL")
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Sorting" \
                    --msgbox "Sorting report alphabetically by name..." $DIALOG_HEIGHT $DIALOG_WIDTH
                bubble_sort_names
                ;;
            "GROSS_SALARY")
                local sort_month_name=${selected_month_names[0]}
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Sorting" \
                    --msgbox "Sorting report by gross salary using $sort_month_name data..." $DIALOG_HEIGHT $DIALOG_WIDTH
                bubble_sort_gross_salary
                ;;
            "NET_SALARY")
                local sort_month_name=${selected_month_names[0]}
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Sorting" \
                    --msgbox "Sorting report by net salary using $sort_month_name data..." $DIALOG_HEIGHT $DIALOG_WIDTH
                bubble_sort_net_salary
                ;;
        esac
        return 0
    else
        dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Cancelled" \
            --msgbox "Operation cancelled by user." $DIALOG_HEIGHT $DIALOG_WIDTH
        clear
        exit 0
    fi
}

display_results() {
    local sort_method=""
    local sort_month_name=""
    
    # Determine what sorting was applied
    local first_month=${selected_months[0]}
    local first_salary=${monthly_salaries_per_month["0_${first_month}"]}
    local second_salary=${monthly_salaries_per_month["1_${first_month}"]}
    
    if [ $first_salary -gt $second_salary ]; then
        sort_method="Sorted by Gross Salary (Highest First)"
        sort_month_name=" - Based on ${selected_month_names[0]}"
    else
        sort_method="Sorted Alphabetically by Name"
        sort_month_name=""
    fi
    
    local result_text=""
    result_text+="MERCEDES BENZ SALARY REPORT - MULTI-MONTH\n"
    result_text+="Generated on: $(date)\n"
    result_text+="$sort_method$sort_month_name\n"
    result_text+="Months: "
    for ((m=0; m<num_months; m++)); do
        result_text+="${selected_month_names[m]}"
        if [ $m -lt $((num_months-1)) ]; then
            result_text+=", "
        fi
    done
    result_text+="\n================================================\n\n"
    
    for ((m=0; m<num_months; m++)); do
        local month_name=${selected_month_names[m]}
        local month_num=${selected_months[m]}
        
        result_text+="\n--- $month_name ---\n"
        result_text+="$(printf "%-15s %-10s %-8s %-8s %-6s %-8s\n" "Name" "Sales" "Bonus" "Gross" "Tax" "Net")\n"
        result_text+="----------------------------------------------------------------\n"
        
        for ((i=0; i<num_salespersons; i++)); do
            result_text+="$(printf "%-15s £%-9d £%-7d £%-7d £%-5d £%-7d\n" \
                "${names[i]}" \
                "${total_sales_per_month["${i}_${month_num}"]}" \
                "${bonuses_per_month["${i}_${month_num}"]}" \
                "${monthly_salaries_per_month["${i}_${month_num}"]}" \
                "${taxes_per_month["${i}_${month_num}"]}" \
                "${net_salaries_per_month["${i}_${month_num}"]}")\n"
        done
        result_text+="\n"
    done
    
    # Use larger dimensions for results display to accommodate the multi-month table
    dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Multi-Month Salary Report" \
        --msgbox "$result_text" 30 90
}

save_to_file() {
    while true; do
        local filename=$(dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Save File" \
            --inputbox "Enter filename:" $DIALOG_HEIGHT $DIALOG_WIDTH 3>&1 1>&2 2>&3)
        if [ $? -eq 0 ]; then
            if [[ "$filename" =~ ^[A-Za-z0-9._-]+$ ]]; then
                local filepath=$(dialog --backtitle "Mercedes Benz Bonus Calculator" --title "File Path" \
                    --inputbox "Enter file path (or '.' for current directory):" $DIALOG_HEIGHT $DIALOG_WIDTH "." 3>&1 1>&2 2>&3)
                if [ $? -eq 0 ]; then
                    if validate_file_path "$filepath"; then
                        local full_path="$filepath/$filename"
                        
                        # Determine what sorting was applied for file header
                        local sort_method=""
                        local sort_month_name=""
                        local first_month=${selected_months[0]}
                        local first_salary=${monthly_salaries_per_month["0_${first_month}"]}
                        local second_salary=${monthly_salaries_per_month["1_${first_month}"]}
                        
                        if [ $first_salary -gt $second_salary ]; then
                            sort_method="Sorted by Gross Salary (Highest First)"
                            sort_month_name=" - Based on ${selected_month_names[0]}"
                        else
                            sort_method="Sorted Alphabetically by Name"
                            sort_month_name=""
                        fi
                        
                        {
                            echo "Mercedes Benz Salesperson Multi-Month Report"
                            echo "Generated on: $(date)"
                            echo "$sort_method$sort_month_name"
                            echo -n "Months: "
                            for ((m=0; m<num_months; m++)); do
                                echo -n "${selected_month_names[m]}"
                                if [ $m -lt $((num_months-1)) ]; then
                                    echo -n ", "
                                fi
                            done
                            echo
                            echo "================================================"
                            
                            for ((m=0; m<num_months; m++)); do
                                local month_name=${selected_month_names[m]}
                                local month_num=${selected_months[m]}
                                
                                echo
                                echo "--- $month_name ---"
                                printf "%-20s %-12s %-12s %-12s %-12s %-12s\n" "Name" "Total Sales" "Bonus" "Gross Sal." "Tax" "Net Salary"
                                echo "--------------------------------------------------------------------------------"
                                for ((i=0; i<num_salespersons; i++)); do
                                    printf "%-20s £%-11d £%-11d £%-11d £%-11d £%-11d\n" \
                                        "${names[i]}" \
                                        "${total_sales_per_month["${i}_${month_num}"]}" \
                                        "${bonuses_per_month["${i}_${month_num}"]}" \
                                        "${monthly_salaries_per_month["${i}_${month_num}"]}" \
                                        "${taxes_per_month["${i}_${month_num}"]}" \
                                        "${net_salaries_per_month["${i}_${month_num}"]}"
                                done
                            done
                        } > "$full_path"
                        
                        if [ $? -eq 0 ]; then
                            dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Success" \
                                --msgbox "Data successfully saved to: $full_path" $DIALOG_HEIGHT $DIALOG_WIDTH
                            break
                        else
                            dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Error" \
                                --msgbox "Could not save file to specified path." $DIALOG_HEIGHT $DIALOG_WIDTH
                        fi
                    else
                        dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Error" \
                            --msgbox "Invalid file path." $DIALOG_HEIGHT $DIALOG_WIDTH
                    fi
                else
                    break
                fi
            else
                dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Error" \
                    --msgbox "Invalid filename. Use only letters, numbers, dots, hyphens, and underscores." $DIALOG_HEIGHT $DIALOG_WIDTH
            fi
        else
            break
        fi
    done
}

main() {
    dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Welcome" \
        --msgbox "Welcome to the Mercedes Benz Multi-Month Salesperson Bonus Calculator!\n\nThis program calculates monthly salary and bonuses for Mercedes Benz salespersons across multiple months.\n\nPress OK to continue." $DIALOG_HEIGHT $DIALOG_WIDTH
    
    get_num_months
    get_months
    get_num_salespersons
    get_salesperson_names
    
    # Data collection for each month and salesperson
    local total_entries=$((num_months * num_salespersons))
    local current_entry=0
    
    for ((m=0; m<num_months; m++)); do
        local month_name=${selected_month_names[m]}
        local month_num=${selected_months[m]}
        
        dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Month Progress" \
            --msgbox "Now collecting data for: $month_name\n\nPlease enter sales data for each salesperson." $DIALOG_HEIGHT $DIALOG_WIDTH
        
        for ((i=0; i<num_salespersons; i++)); do
            get_salesperson_data_for_month "$month_name" "$month_num" $i
            
            current_entry=$((current_entry + 1))
            local progress=$(( current_entry * 100 / total_entries ))
            echo "$progress" | dialog --backtitle "Mercedes Benz Bonus Calculator" \
                --gauge "Collecting data... ($current_entry/$total_entries)" 6 50 0
        done
    done
    
    echo "50" | dialog --backtitle "Mercedes Benz Bonus Calculator" \
        --gauge "Processing salary calculations..." 6 50 0
    process_all_data
    
    echo "75" | dialog --backtitle "Mercedes Benz Bonus Calculator" \
        --gauge "Preparing report options..." 6 50 0
    
    echo "100" | dialog --backtitle "Mercedes Benz Bonus Calculator" \
        --gauge "Calculations complete!" 6 50 0
    
    get_sort_preference
    display_results
    
    dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Save Results" \
        --yesno "Do you want to save the results to a file?" $DIALOG_HEIGHT $DIALOG_WIDTH
    if [ $? -eq 0 ]; then
        save_to_file
    fi
    
    dialog --backtitle "Mercedes Benz Bonus Calculator" --title "Complete" \
        --msgbox "Program completed successfully!\n\nThank you for using Mercedes Benz Multi-Month Bonus Calculator." $DIALOG_HEIGHT $DIALOG_WIDTH
    
    clear
}

main
