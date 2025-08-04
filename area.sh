#!/bin/bash



# Function to check if input is a valid number (integer or float)
is_number() {
    [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

# Show tool description
whiptail --title "Rectangle Area Calculator" --msgbox \
"This tool calculates the area of a rectangle.\n\n\
-You will first select the unit of your input dimensions: centimetres (cm) or inches (in).\n\
-Then you will enter the height and width in that unit.\n\
-The result can be displayed in square metres (m²) or square inches (in²).\n\n\
-Only valid numbers are accepted (e.g., 12 or 3.14). You can try again or exit anytime." 16 65

while true; do

    # Ask for input dimension unit preference
    INPUT_UNIT=$(whiptail --title "Select Input Unit" --radiolist \
    "In what unit will you enter the dimensions?" 12 60 2 \
    "cm" "Centimetres (cm)" ON \
    "inch" "Inches (in)" OFF 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && exit 0

    # Height input and validation
    while true; do
        HEIGHT=$(whiptail --title "Enter Height" --inputbox "Enter the height of the rectangle (in $INPUT_UNIT):" 10 60 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && exit 0
        if is_number "$HEIGHT"; then
            break
        else
            whiptail --title "Invalid Input" --msgbox "Please enter a valid number for height (e.g., 12 or 3.14)." 8 60
        fi
    done

    # Width input and validation
    while true; do
        WIDTH=$(whiptail --title "Enter Width" --inputbox "Enter the width of the rectangle (in $INPUT_UNIT):" 10 60 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && exit 0
        if is_number "$WIDTH"; then
            break
        else
            whiptail --title "Invalid Input" --msgbox "Please enter a valid number for width (e.g., 12 or 3.14)." 8 60
        fi
    done

    # Convert input to cm if input was in inches
    if [ "$INPUT_UNIT" == "inch" ]; then
        HEIGHT_CM=$(echo "scale=4; $HEIGHT * 2.54" | bc)
        WIDTH_CM=$(echo "scale=4; $WIDTH * 2.54" | bc)
    else
        HEIGHT_CM=$HEIGHT
        WIDTH_CM=$WIDTH
    fi

    # Unit selection for output
    UNIT=$(whiptail --title "Select Output Unit" --radiolist \
    "How would you like the area to be displayed?" 12 60 2 \
    "metres" "Convert to square metres (m²)" ON \
    "inches" "Convert to square inches (in²)" OFF 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && exit 0

    # Area calculation in cm^2
    AREA_CM=$(echo "$WIDTH_CM * $HEIGHT_CM" | bc)

    if [ "$UNIT" == "metres" ]; then
        AREA_METRES=$(echo "scale=4; $AREA_CM / 10000" | bc)
        RESULT="Area: $AREA_METRES m²"
    else
        AREA_INCHES=$(echo "scale=2; $AREA_CM / (2.54 * 2.54)" | bc)
        RESULT="Area: $AREA_INCHES in²"
    fi

    # Show result with original inputs and units
    whiptail --title "Calculation Result" --msgbox \
"Height: $HEIGHT $INPUT_UNIT\nWidth: $WIDTH $INPUT_UNIT\n\n$RESULT" 12 60

    # Ask to repeat or exit
    if (whiptail --title "Repeat Calculation" --yesno "Would you like to calculate another area?" 10 60); then
        continue
    else
        whiptail --title "Exit" --msgbox "Thank you for using the Rectangle Area Calculator." 8 50
        exit 0
    fi

done
