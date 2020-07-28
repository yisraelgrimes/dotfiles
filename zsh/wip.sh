#! /usr/bin/zsh
# Sourced by .bash_profile
# Used to create shortcuts for current/frequently used projects.
# #####################################


# Copy String
pb() {
  echo "$@" | pbcopy
}

# Copy History to clipboard
history_copy() {
	history -i
  history -i | pbcopy
}


sssh() {
	if [[ -z "$1" ]] || [[ "$1" == "help" ]]; then
		echo "Shortcut to ssh into commonly accessed servers"
		echo "ssh <server> <user>"
		echo "Servers: fueled | rsn | aureus"
		echo "User: root | basic"
		echo "      root is default"
	else
		export SERVER="$1"
		export USER="$2"

		# Set default user as "root"
		if [[ -z "$USER" ]]; then
			USER="root"
		fi
		# Get the info
		include "$SYNC_DIR/manual_sync/tacos"
		# Do the thing
		ssh "$USER"@"$ADDRESS"
	fi
	unset SERVER USER ADDRESS PW
}


# #####################################
# IN PROGRESS: Download placeholder image from placeholder.com
# #####################################
# Default
# http://via.placeholder.com/350x150
# Image format (either jpg, jpeg, png, gif)
# http://via.placeholder.com/350x150.jpg
# Custom Text
# http://via.placeholder.com/350x150?text=This+Is+Great!
# Custom Colors
# http://via.placeholder.com/350x150/000000/ffffff
#
#
placeholder() {
	size="$1"
	format="$2"

	if [ ! "$format" ]; then format=png; fi

	# curl -O "http://via.placeholder.com/$size"".$format"
	wget -P "$HOME/Desktop" "http://via.placeholder.com/$size"".$format"
}


# #####################################
# Create .vscode/settings.json file if it doesn't exist. Open it if it does.
# Used for the VSCode extention "Peep" -- http://tinyw.in/ZKDN
# #####################################
function peep() {
	dir="./.vscode"
	file="settings.json"
	fullpath="$dir/$file"

	if [ ! -e "$dir" ]; then
		mkdir "$dir"
	fi

	if [ ! -e "$fullpath" ]; then
		{
			echo "{"
			echo "  \"files.exclude\": {"
			echo "    \"node_modules/\": true,"
			echo "    \".env\": true,"
			echo "    \"sanity.json\": true,"
			echo "    \"lerna.json\": true,"
			echo "    \"netlify.toml\": true,"
			echo "    \"gulpfile.js\": true,"
			echo "    \"package.json\": true,"
			echo "    \"README*.md\": true,"
			echo "    \"readme*.txt\": true,"
			echo "    \"humans.txt\": true,"
			echo "    \"robots.txt\": true,"
			echo "    \".gitignore\": true,"
			echo "    \".jshintignore\": true,"
			echo "    \".eslintignore\": true,"
			echo "    \".eslintrc.js\": true,"
			echo "    \".prettierrc\": true,"
			echo "    \".sass-lint.yml\": true,"
			echo "    \".editorconfig\": true,"
			echo "    \".stylishcolors\": true,"
			echo "    \".pug-lintrc\": true,"
			echo "    \"languages/\": true,"
			echo "    \"LICENSE*\": true,"
			echo "    \"yarn.lock\": true,"
			echo "    \"package-lock.json\": true,"
			echo "    \"*.log\": true,"
			echo "    \".git/\": true,"
			echo "    \"*.ico\": true,"
			echo "    \"*.png\": true,"
			echo "    \"*.jpg\": true"
			echo "  }"
			echo "}"
		} >> "$fullpath"
	fi

	# Open file in editor
	editor "$fullpath"
}


# #####################################
# Sync local iTunes music with NAS
# #####################################
tune_sync() {

	cmd="$1"
	opts="$2"
	# Computer-specific Variables
	if [ "$IS_IMAC" = true ]; then
		# Set the backup directory name
		currentMac="imac"
		# Set iTunes location
		# @TEST
		# slaveParentP="$HOME/Desktop/test-slave/Music/iTunes"
		slaveParentP="$HOME/Music/iTunes"
	else
		currentMac="macbook"
		# @TEST
		# slaveParentP="$HOME/Desktop/test-slave/Music/iTunes"
		slaveParentP="/Volumes/media-drive/Music/iTunes"
		# Make sure local media drive is mounted before continuing
		if ! mount|grep -q "/Volumes/media-drive"; then
			echo "Make sure your Media Drive SD is mounted and try again"
			return
		fi
	fi

	slaveP="$slaveParentP/iTunes Media"
	volumeNas="/Volumes/homes"
	# @TEST
	# masterParentP="$HOME/Desktop/test-master/music_sync-master/iTunes"
	masterParentP="/Volumes/homes/music_sync-master/iTunes"
	masterP="$masterParentP/iTunes Media"
	backupMasterP="$masterParentP/_removed/master/$DATE"
	backupSlaveP="$masterParentP/_removed/$currentMac/$DATE"
	database="iTunes Library.itl"

	# Make sure NAS is mounted before continuing
	if ! mount|grep -q $volumeNas; then
		echo "Make sure your NAS is mounted and try again"
		return
	fi

	# FROM Local to NAS
	if [ "$cmd" == "push" ]; then
		# Remove NAS files that aren't in Local
		if [ "$opts" == "-d" ]; then
			rsync -rt --progress --delete --backup --backup-dir="$backupMasterP" "$slaveP" "$masterParentP"
		# Add changed files to NAS, don't delete
		else
			rsync -rt --progress "$slaveP" "$masterParentP"
		fi
		# Update iTunes library data file on NAS
		rsync -t --progress "$slaveParentP/$database" "$masterParentP"

	# FROM NAS to Local
	elif [ "$cmd" == "pull" ]; then
		# Remove Local files that aren't in NAS
		if [ "$opts" == "-d" ]; then
			rsync -rt --progress --delete --backup --backup-dir="$backupSlaveP" "$masterP/" "$slaveP"

		# Add changed files to Local, don't delete
		else
			rsync -rt --progress "$masterP/" "$slaveP"
		fi

		# Update iTunes library data file on Local
		rsync -t --progress "$masterParentP/$database" "$slaveParentP"

	# Send Help!
	else
		echo "Add Help Info Here"
	fi

	unset cmd opts currentMac database
	unset slaveParentP slaveP
	unset masterParentP masterP volumeNas volumeMbpMedia
	unset backupMasterP backupSlaveP
}


# #####################################
# Backup iPhotos library
# #####################################
backup-photolibrary() {
	bt=$(date "+%Y_%m_%d")

if [ $# -eq 0 ]; then # if no paths are passed, use defaults
	des=$(df -lh | awk -F " " '{print $9}' | tail -n 1) # assumes that the most recently-mounted disk is the one you want
	src=("$HOME/Pictures/Photos Library.photoslibrary/Masters/") # default path
	if [ -e "$src" ]; then # checks if file exists
		mkdir "$des/PhotosBackup/$bt"
		rsync -aPv "$src" "$des/PhotosBackup/$bt/"
	else
		echo "No Photos Library, or its filename is not default."
		exit
	fi
else # provide paths at command-line
	mkdir "$2/PhotosBackup/$bt"
	rsync -aPv "$1/" "$2/PhotosBackup/$bt/"
fi
}