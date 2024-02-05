#!/bin/bash

ERR_USAGE="Usage: ./parallelograms.sh"
ERR_INPUT="Parallelogram size must be [2,20]."
MSG_PROMPT="Enter the size of the parallelograms to display: "
MSG_REPLAY="Run again? (y/N): "
U_LIMIT=20
L_LIMIT=2


# print_pattern
# Function that prints out a parallelogram pattern row by row. The pattern
# should consist of:
#
# [spaces-stars] space [stars-spaces] space [spaces-stars] space [stars]\n
#
# where
#   [spaces-stars] is a pattern consisting of spaces and stars up to a given
#                  width that will result in a triangle if printed alone
#   space          is a single space separating the blocks
#   [stars]        is a pattern consisting of only stars for the 4th triangle
#   \n             is the newline character. Printed with `echo`
#
# A parallelogram of size three looks like:
#
# *** *     * ***
#  ** **   ** **
#   * *** *** *
#
# USAGE
#   print_pattern numrows
#
# INPUT
#   numrows: number of rows of the parallelogram that should be printed
function print_pattern {
   
    ind=0

    while [ $ind -lt "$1" ]; do
        # Spaces before first triangle
        for ((inner=0; inner < $ind; inner++)); do
            echo -n " "
        done

        num_stars1=`expr $1 - $ind`
        for ((inner=0; inner < $num_stars1; inner++)); do
            echo -n "*"
        done

        echo -n " " # This line is necessary for padding

       
        num_stars2=`expr 1 + $ind`
	for((inner=0; inner < $num_stars2; inner++)); do
	    echo -n "*"
	done


       
	num_s1=`expr $ind \* 2`
	num_s2=`expr $1 \* 2`
	for ((inner=`expr $num_s2 - 1`; inner > $num_s1  ; inner-=1)); do
    	    echo -n " "
	done

     
        num_stars3=`expr 1 + $ind`
	for((inner=0; inner < $num_stars3; inner++)); do
	    echo -n "*"
	done

	echo -n " "

	

        num_stars4=`expr $1 - $ind`
	for((inner=0; inner < $num_stars4; inner++)); do
	    echo -n "*"
	done



        ind=`expr $ind + 1`
        echo # Print newline
    done
}

# print_usage_and_exit
# Function that prints an error message concerning incorrect usage to stderr and
# then terminates the script with exit status code 1
#
# then terminates the script with exit status code 1
#
# USAGE
#   print_input_error
function print_usage_and_exit {
    echo "Error "${ERR_USAGE}"">&2
    exit 1
}

# print_input_error
# Function that prints an error to stdout notifying the user of the correct
# range of valid input values. This function SHOULD NOT terminate the script.
#
# USAGE
#   print_input_error
function print_input_error {
    echo "Error: "${ERR_INPUT}"">&1
}

# main
# Function that interfaces with the user. The function should prompt the user
# for the size of the parallelograms, check that the user input is within range,
# and then print the parallelograms. After printing, the function should ask the
# user if they want to "Run again? (y/N): ". If "y" or "Y" are pressed, the
# loop will run again. Otherwise, the loop will exit and the function will
# return.
#
# USAGE
#   main
function main {

    # Check that the number of input arguments is correct
    if [ $# -gt 0 ]; then
        print_usage_and_exit
    fi

    # Infinite Loop
    while [ 0 -ne 1 ]; do
        # Prompt the user to input a value
        echo -n "$MSG_PROMPT"
        read value

        # Check the user input to ensure it is safe and within range
        if ! [ "$value" -eq "$value" ] &> /dev/null; then
            # The above test-command checks that the input argument is a valid
            # integer by trying to convert it to a number. If the conversion
            # fails, then [ "$1" -eq "$1" ] has an exit status code of 2, which
            # can be inverted using !. An improper value results in an error.
            # Instead of displaying the error, send it to the null device
            # (/dev/null)
            print_input_error

            continue

       
        elif ! [[ "$value" -ge "$L_LIMIT" && "$value" -le "$U_LIMIT" ]]; then
            print_input_error

            continue
        fi

        # Print newline for clarity
        echo

        # Call function with number parsed
        print_pattern $value

        
        echo -n "$MSG_REPLAY"
        read input



      
        if ! [[ $input == "Y" || $input == "y" ]]; then
            break
        fi
    done
}



function ??? {
    echo "WARNING! TODO on line ${BASH_LINENO[0]} not implemented (or ??? was" \
         "not removed)" 1>&2
}

main "$@"

echo "Script finished."


