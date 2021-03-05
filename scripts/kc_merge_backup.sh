#!/bin/bash

######################################################
#
# Merging Kerio Connect Backups with Live Mail Store
#
######################################################

# Problem:
# Currently, if a customer wants to recover emails from a backup, there is not an easy way from the terminal/filesystem to merge them together. 
# We can suggest the use of Outlook or another Email Client to add the emails, but if you were to merge the backup emls with the live mailstore, 
# There is a problem of file name conflicts. 
#Backup
#	`-- User1
#		`-- INBOX
#			`-- #msgs
#				`-- 00000001.eml
#					00000002.eml
#
#Mailstore
#	`-- User1
#		`-- INBOX
#			`-- #msgs
#				`-- 00000001.eml
#
# In this situation, if you were to add the emls from the Backup to the Mailstore, the existing eml 00000001.eml would be over-written.
# Clearly, this is not ideal, and the only official solution we have for restoring backup data is KMS Recover.
# Unfortunately, KMS Recover deletes the mailstore before it recovers the backup, which is not always ideal. 

# Proposed Solution:
# Using the following high-level logic, we can loop through each folder in the backup to properly merge the two collections of emls:
# 1) Loop through the backup to find folders containing emls.
# 2) Match the folder found to the folder within the mailstore.
# 3) Build a dictionary reference of all folders that need to be merged.
# 4) Loop through the folders and perform the following logic to each: 
## 1) Copy eml from source folder to target folder, and rename on collision using cp with the --backup flag; we will likely want to retain metadata with the -p flag as well
## 1.1) Ideally, using the special case of --backup and --force will create a backup of the source instead of the target conflict.
## 1.2) Using the --suffix flag we can set the backup to a unique identifier. 
## 2) Once copy is completed, check target folder to find the "newest" eml file name using "ls -A1 | tail -1"
## 3) Assign the name to a variable.
## 4) Loop through each folder and find eml backups with the unique identifier
## 5) For Each, rename backup to variable name incremented (in base16) + 1

# Considerations: 
# The Mail Server will need to be stopped to prevent any new emls from arriving during the script run.
# We need to ensure that the Base16 increment is accurately labelling. 


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















