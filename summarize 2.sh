#!/bin/bash

LIST_TITLES=("Moby-Dick; or, The Whale" \
             "Gadsby"                   \
             "Pride and Prejudice")
LIST_AUTHORS=("Herman Melville"         \
              "Ernest Vincent Wright"   \
              "Jane Austin")
LIST_ADDR=("https://www.gutenberg.org/files/2701/2701-0.txt"    \
           "http://www.gutenberg.org/files/47342/47342.txt"     \
           "http://www.gutenberg.org/files/1342/1342-0.txt")
LIST_FILES=("mobydick.txt"              \
            "gadsby.txt"                \
            "pride and prejudice.txt")

DIR_LIBRARY="library"

ERR_USAGE="Usage: ./summarize.sh"
ERR_INPUT="Invalid book. Selection must be [1, ${#LIST_TITLES[@]}]"
MSG_PROMPT="Which book from the above list would you like to proccess? "

LETTERS=(a b c d e f g h i j k l m n o p q r s t u v w x y z)

# atoi
# Function converts an ascii character to the corresponding integer value
function atoi {
    printf '%d' "'$1"
}

# toupper
# Function converts all input characters to uppercase
function toupper {
    echo ${1^^}
}

# download_book
# Function downloads a book from the addresses listed in LIST_ADDR and saves it
# in the library (DIR_LIBRARY) and corresponding file in LIST_FILES. On any
# error, the function will cause the script to terminate with exit code 1.
#
# USAGE
#   download_book ind
#
# INPUT
#   ind: index of the book to be downloaded
function download_book {
    ind="$1"
    if  [ "$ind" -le ${#LIST_ADDR[@]} ] &> /dev/null &&        \
        [ "$ind" -le ${#LIST_TITLES[@]} ] &> /dev/null &&      \
        [ "$ind" -le ${#LIST_AUTHORS[@]} ] &> /dev/null &&     \
        [ "$ind" -le ${#LIST_FILES[@]} ] &> /dev/null
        then
        echo "Downloading \"${LIST_TITLES[$ind]}\" from ${LIST_ADDR[$ind]}."
        if curl "${LIST_ADDR[$ind]}" > "${DIR_LIBRARY}/${LIST_FILES[$ind]}" 2> /dev/null; then
            echo "Download success!"
        else
            echo "Download error."
            exit 1
        fi
    else
        echo "Index $ind is out of bounds."
        exit 1
    fi

    sleep 1
}

OFFSET_A=`atoi A`



NUM_LINES_TO_PROCESS=100    # Controls the number of lines that are processed

# check_library
# Function checks if the directory saved in DIR_LIBRARY exists or not.
# If the directory exists, then "Found library at ${LIBPATH}" is printed, where
# LIBPATH is the full path to the directory starting at root (/), and the
# function returns with status code 0.
# If the directory does not exist, then "Making ${DIR_LIBRARY}" is printed,
# where DIR_LIBRARY is the relative path of the library as defined above, the
# directory is made, and the function returns with status code 1.
#
# USAGE
#   check_library
function check_library {
    if [[ -d "${DIR_LIBRARY}" ]]; then
	LIBPATH=$(pwd)/"${DIR_LIBRARY}" # Changed hardcoded path to dynamic one
        echo "Found library at ${LIBPATH}"
        return 0
    else
        echo "Making ${DIR_LIBRARY}"
        mkdir "${DIR_LIBRARY}" 
        return 1
    fi
}

# check_book
# Function checks if the .txt file of the book selected by ind exists or not.
# If the .txt file exists, then the function returns with status code 0.
# If file does not exist, then "[Download Required]" is printed and the
# function returns with status code 1.
#
# USAGE
#   check_book ind
#
# INPUT
#   ind: index of the book to be checked
function check_book {
    variable="${DIR_LIBRARY}"/"${LIST_FILES["$1"]}"

    if [[ -e "${variable}" ]]; then 
        return 0
    else
        echo "[Download Required]" 
        return 1
    fi
}

# count_characters
# Function that counts the number of occurrences of each ASCII character from
# the first lines in a file up to NUM_LINES_TO_PROCESS. The count is stored in
# an array and then the counts for each letter are printed to the terminal with
# upper and lowercase counts summed together.
#
# USAGE
#   count_characters path
#
# INPUT
#   path: path to the file being processed (example "path/file.txt")
function count_characters {
    path_in="$1"

    print_line_statistics "$path_in"

    Array=()

    for (( i=0; i < 256; i++ )); do
        Array+=(0)
    done


    line_num=0
    while read line_in; do
        ((line_num++))
        #echo "Line ${line_num}" # This line may be useful for debugging

        for ((inner=0; inner < ${#line_in}; inner++)); do
	    character=${line_in:$inner:`expr $inner + 1`}
	    (( Array[`atoi "$character"`]++ ))
        done


        if [[ "${line_num}" -eq "$NUM_LINES_TO_PROCESS" ]] ; then
            break
        fi
    done < "${path_in}"


    echo
    echo "--Letter Count--"
    for letter in "${LETTERS[@]}"; do
        letter_upper=`toupper $letter`
        # TODO: add your code here and modify the echo statement
	sum=$((${Array[`atoi "$letter_upper"`]:-0} + ${Array[`atoi "$letter"`]:-0}))
        echo "$letter_upper $sum"
    done
}

# print_booklist
# Function prints out the titles and authors of each book listed in LIST_TITLES.
# Each book is prefaced by a number and right paranthesis that begins at 1. The
# title and author should be separated using " by ". If the .txt file is not
# located in the DIR_LIBRARY folder, then add the text [Download Required] after
# the book and author.
#
# For example:
# 1) Moby-Dick; or, The Whale by Herman Melville
# 2) Gadsby by Ernest Vincent Wright [Download Required]
# 3) Pride and Prejudice by Jane Austin [Download Required]
#
# USAGE
#   print_booklist
function print_booklist {
    echo
    echo "The following books are available:"
    
    for (( i=0; i < "${#LIST_TITLES[@]}"; i++ )); do
	    listval=`expr ${i} + 1`
	    combine="${listval}) "${LIST_TITLES[$i]}" by "${LIST_AUTHORS[$i]}" `check_book $i`"
	    echo "${combine}"
    done
}

# print_line_statistics
# Function that prints the total number of lines in an input text file, the
# number of lines to be processed based on the variable NUM_LINES_TO_PROCESS,
# and the percentage of the file that will be parsed based on those line counts.
# Percentage ranges between 0.00 and 100.00 and must be calculated to exactly
# 2 decimal places. (HINT: Try looking at how bc should be used.)
#
# USAGE
#   print_line_statistics path
#
# INPUT
#   path: path to the file being processed (example "path/file.txt")
function print_line_statistics {
    path_in="$1"

    numolines=`wc -l < "${path_in}"`
    echo "${path_in} has ${numolines} lines"
    var=$(echo "$NUM_LINES_TO_PROCESS/$numolines*100" | bc -l)
    percentage=$(echo "scale=2;$var/1" | bc)
    echo "Processing the first $NUM_LINES_TO_PROCESS lines ($percentage%)"
}

# print_input_error_and_exit
# Function that prints an error to stdout notifying the user of the correct
# range of valid input values and then terminates the script with exit status
# code 1
#
# USAGE
#   print_input_error
function print_input_error_and_exit {
    echo "Error: "${ERR_INPUT}"">&1
    exit 1
}

# main
# Function that prints a list of available books for processing, takes in a user
# selection, and then performs a count of the letter frequency within the
# selected book. If the .txt file of the book is not in the library (as denoted
# by the folder at DIR_LIBRARY), then the .txt file is downloaded.
#
# USAGE
#   main
function main {
    # Check that a library folder exists
    check_library

    # Print a list of available books
    print_booklist

    
    echo -n "$MSG_PROMPT"
    read ind_book
    ind_book=$(($ind_book - 1))

    # Check that the user input is an integer and in a valid range
    if ! [[ "$ind_book" -ge 0 && "$ind_book" -lt "${#LIST_TITLES[@]}" ]]; then
        # The above test-command checks that the input argument is a valid
        # integer by trying to convert it to a number. If the conversion
        # fails, then [ "$1" -eq "$1" ] has an exit status code of 2, which
        # can be inverted using !.
	print_input_error_and_exit
   
    
    else
        var="${DIR_LIBRARY}"/"${LIST_FILES[$ind_book]}"

        # Check if the book has been downloaded already by using the check_book
        # properly with echo)
        if check_book "${var}" &> /dev/null; then
            echo "\"${LIST_TITLES[$ind_book]}\" found in library"
        else
            echo "\"${LIST_TITLES[$ind_book]}\" not found in library"
            download_book "${ind_book}"
        fi

        count_characters "$var"
    fi
}


function ??? {
    echo "WARNING! TODO on line ${BASH_LINENO[0]} not implemented (or ??? was" \
         "not removed)" 1>&2
}

if [ $# -gt 0 ]; then
    echo "$ERR_USAGE"
    exit 1
fi

main


