# kc-justify
A utility for merging Kerio Connect Backup files into an existing Mail Store. Avoids the hassle of having to completely replace all items through the use of the provided KMSRecover Utility.

# Problem:
Currently, if a customer wants to recover emails from a backup, there is not an easy way from the terminal/filesystem to merge them together. 
We can suggest the use of Outlook or another Email Client to add the emails, but if you were to merge the backup emls with the live mailstore, 
There is a problem of file name conflicts. 

Backup
	`-- User1
		`-- INBOX
			`-- #msgs
				`-- 00000001.eml
					00000002.eml

Mailstore
	`-- User1
		`-- INBOX
			`-- #msgs
				`-- 00000001.eml

 In this situation, if you were to add the emls from the Backup to the Mailstore, the existing eml 00000001.eml would be over-written.
 Clearly, this is not ideal, and the only official solution we have for restoring backup data is KMS Recover.
 Unfortunately, KMS Recover deletes the mailstore before it recovers the backup, which is not always ideal. 

# Proposed Solution:
 Using the following high-level logic, we can loop through each folder in the backup to properly merge the two collections of emls:
 1) Loop through the backup to find folders containing emls.
 2) Match the folder found to the folder within the mailstore.
 3) Build a dictionary reference of all folders that need to be merged.
 4) Loop through the folders and perform the following logic to each: 
 a) Copy eml from source folder to target folder, and rename on collision using cp with the --backup flag; we will likely want to retain metadata with the -p flag as well
 a.1) Ideally, using the special case of --backup and --force will create a backup of the source instead of the target conflict.
 a.2) Using the --suffix flag we can set the backup to a unique identifier. 
 b) Once copy is completed, check target folder to find the "newest" eml file name using "ls -A1 | tail -1"
 c) Assign the name to a variable.
 d) Loop through each folder and find eml backups with the unique identifier
 e) For Each, rename backup to variable name incremented (in base16) + 1

# Considerations: 
 The Mail Server will need to be stopped to prevent any new emls from arriving during the script run.
 We need to ensure that the Base16 increment is accurately labelling. 
