#!/bin/bash

if (( $# != 2))
then
	echo ""
	echo "Script will check destination directory for the highest HEX eml name, and then"
	echo "rename all the emls in the source to incrementing upwards."
	echo ""
	echo "Missing Parameters. Please provide Source and Destination directories."
	echo "USAGE: $0 source_directory destination_directory"
	echo ""
	exit
fi

#######################################################
# Variables
#######################################################

source_path=$1
dest_path=$2

newest_eml=

##########################
# Functions
##########################

function find_newest_eml {
	local check="$(ls -A1p $dest_path | grep -v / | tail -1)"

	if [ -z "$check" ]
	then
		newest_eml=00000000.eml
	else
		newest_eml=$check
	fi
}

# Strips the eml of the ext so that it can be converted and stored to newest_eml variable
function strip_eml {
	local EML=$1
	echo "${EML%%.*}"
}

function increment_eml {
    local EML=$1
    local EML2="$(echo 'obase=ibase=16;'$EML'+1' | bc)"
	local EML3=$(printf "%08d" $EML2)
	echo $EML3
}

function rename_eml {
	local EML=$1
	echo $EML
	local stripped_newest="$(strip_eml $newest_eml)"
	echo $stripped_newest
	local incremented="$(increment_eml $stripped_newest)"
	echo $incremented
	local incremented_full="${incremented}.eml"
	echo $incremented_full
	newest_eml=$incremented_full

    cp $1 $dest_path/$incremented_full
}

########
# Body
########

find_newest_eml
find $source_path -type f -name '*eml' | while read file; do rename_eml "$file"; done
