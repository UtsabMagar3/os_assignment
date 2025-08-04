#!/bin/bash

# Car average prices (GBP)
declare -A car_prices=(
  ["A Class"]=31095
  ["B Class"]=33162
  ["C Class"]=42537
  ["E Class"]=54437
  ["AMG C65"]=79660
)

BASIC_SALARY=2000

# Validate number input (integer)
is_number() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

# Validate name input (letters and spaces only)
is_valid_name() {
  [[ "$1" =~ ^[A-Za-z\ ]+$ ]]
}

# Calculate bonus based on total sales
calculate_bonus() {
  local sales=$1
  if (( sales > 650000 )); then
    echo 30000
  elif (( sales > 500000 )); then
    echo 25000
  elif (( sales > 400000 )); then
    echo 20000
  elif (( sales > 300000 )); then
    echo 15000
  elif (( sales >= 200000 )); then
    echo 10000
  else
    echo 0
  fi
}

# Calculate tax based on UK tax bands
calculate_tax() {
  local salary=$1
  local taxable=0
  local tax=0
  local pa=12500

  if (( salary <= pa )); then
    tax=0
  else
    taxable=$(( salary - pa ))
    if (( taxable <= 37500 )); then
      # Basic rate 20%
      tax=$(echo "$taxable * 0.20" | bc)
    elif (( taxable > 37500 && taxable <= 125000 )); then
      # 37500 at 20% + rest at 40%
      basic_tax=$(echo "37500 * 0.20" | bc)
      higher_tax=$(echo "($taxable - 37500) * 0.40" | bc)
      tax=$(echo "$basic_tax + $higher_tax" | bc)
    else
      # Above 150k not specified - let's treat all above 125k as 40%
      basic_tax=$(echo "37500 * 0.20" | bc)
      higher_tax=$(echo "($taxable - 37500) * 0.40" | bc)
      tax=$(echo "$basic_tax + $higher_tax" | bc)
    fi
  fi

  echo "$tax"
}

# Bubble sort salespersons array by name
bubble_sort_names() {
  local -n names=$1
  local n=${#names[@]}
  local i j
  for ((i=0; i < n; i++)); do
    for ((j=0; j < n - i - 1; j++)); do
      if [[ "${names[j]}" > "${names[$((j+1))]}" ]]; then
        # Swap
        temp=${names[j]}
        names[j]=${names[$((j+1))]}
        names[$((j+1))]=$temp
      fi
    done
  done
}

# Main script

echo "Enter month (e.g. July):"
read MONTH
while ! [[ $MONTH =~ ^[A-Za-z]+$ ]]; do
  echo "Invalid month. Enter letters only."
  read MONTH
done

echo "Enter number of salespersons (3 to 20):"
read NUM
while ! is_number "$NUM" || (( NUM < 3 || NUM > 20 )); do
  echo "Enter a valid number between 3 and 20."
  read NUM
done

# Arrays to hold data for sorting and output
declare -a salespersons
declare -A total_sales
declare -A bonuses
declare -A taxes
declare -A net_salaries

for ((i=1; i <= NUM; i++)); do
  while true; do
    echo "Enter name of salesperson #$i:"
    read NAME
    if is_valid_name "$NAME"; then
      break
    else
      echo "Invalid name. Use letters and spaces only."
    fi
  done

  salespersons+=("$NAME")

  # For each model, ask how many sold by this person
  TOTAL=0
  echo "Enter number of cars sold for each model by $NAME:"
  for model in "${!car_prices[@]}"; do
    while true; do
      echo "  $model (£${car_prices[$model]} each):"
      read QTY
      if is_number "$QTY"; then
        break
      else
        echo "  Please enter a valid integer number (0 or more)."
      fi
    done
    # Calculate subtotal for this model
    SUBTOTAL=$(( QTY * car_prices[$model] ))
    TOTAL=$(( TOTAL + SUBTOTAL ))
  done

  total_sales["$NAME"]=$TOTAL
  BONUS=$(calculate_bonus $TOTAL)
  bonuses["$NAME"]=$BONUS

  SALARY=$(( BASIC_SALARY + BONUS ))

  TAX=$(calculate_tax $SALARY)
  taxes["$NAME"]=$TAX

  # net salary = salary - tax (tax may have decimals, so use bc)
  NET=$(echo "$SALARY - $TAX" | bc)
  net_salaries["$NAME"]=$NET
done

# Sort salespersons by name using bubble sort
bubble_sort_names salespersons

# File output
echo "Enter file name to save results (e.g. output.txt):"
read FILE_NAME

echo "Enter full path to save the file (e.g. /home/user/Documents):"
read FILE_PATH

FULL_PATH="${FILE_PATH%/}/$FILE_NAME"  # Ensure single slash

# Write header
echo "Sales Report for $MONTH" > "$FULL_PATH"
echo "-----------------------------------" >> "$FULL_PATH"
echo -e "Name\tTotal Sales\tBonus\tTax\tNet Salary" >> "$FULL_PATH"

# Output sorted results
for name in "${salespersons[@]}"; do
  echo -e "$name\t£${total_sales[$name]}\t£${bonuses[$name]}\t£${taxes[$name]}\t£${net_salaries[$name]}" >> "$FULL_PATH"
done

echo "Report saved to $FULL_PATH"

# Display results in console sorted by name
echo -e "\nSalespersons sorted by name with net salary:"
for name in "${salespersons[@]}"; do
  echo "$name : Net Salary = £${net_salaries[$name]}"
done

