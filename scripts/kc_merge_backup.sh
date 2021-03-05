#!/bin/bash

#######################################################
# Variables
#######################################################

backup_path=$1
mailstore_path=$2


newest_eml=
newest_eml_decimal=



##########################
# Functions
##########################

function check_folder_path {
	echo "check_folder_path"
}

function match_backup_items {
	echo "match_backup_items"
}

function merge_backup_items {
	echo "merge_backup_items"
}


### Functions that will handle the filenames for Merge collision

# Pass in the current directory to return the file with highest HEX name

function find_newest_eml {
	ls -A1p $1 | grep -v / | tail -1
}

# Strips the eml of the ext so that it can be converted and stored to newest_eml variable
function strip_eml {
	local EML=$1
	echo "${EML%%.*}"
}

# Used to convert the eml filenames into decimal to increment
function hex_to_decimal {
	echo "ibase=16; $1" | bc
}

# Used to convert the incremented decimal eml name back into Hex for filename assignment
function decimal_to_hex {
	echo "ibase=10; obase=16; $1" | bc
}


### Functions for locating the backed-up emls due to collision

# Accepts an eml file with unique identifier due to collision
# Perform check against the newest_eml variable
# Use local variable to assign the incremented eml name in decimal
# Rename the collision eml to new local variable

# Important Usage note: There is not a convenient way of assigning Global Variables from Function in Bash that I can see.
# When calling rename_eml, we need to be sure that we also perform the assignment of the echo to newest_eml_decimal.

# We could potentially nest the variable, and the function calls within another function to avoid this.
# I will explore that further.

function rename_eml {
	local EML=$1
	local stripped_newest="$(strip_eml $newest_eml)"
	local decimal_newest="$(hex_to_decimal $stripped_eml)"
	local incremented_name="$(decimal_newest + 1)"
	local new_hex="$(decimal_to_hex $incremented_name)"
	local new_final="${new_hex}.eml"
	# We might have to use a Find -exec rename on this, we will see. Unclear of benefits one way or another?
	mv $EML $new_final
	
	echo "$incremented_name"
}

# Function to find and run the rename function via loop. 

function find_collision_emls {
	# Does this work as expected :o 
	find . -name '*~' | while read file; do rename_eml "$file"; done

}

echo $backup_path
echo $mailstore_path
echo $newest_eml
echo $newest_eml_decimal















