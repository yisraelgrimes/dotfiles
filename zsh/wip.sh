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

	if [ ! -e "$dir" ]; then
		mkdir "$dir"
	fi

	if [ ! -e "${dir}/.gitignore" ]; then
		echo "**" >> "${dir}/.gitignore"
	fi

	if [ ! -e "${dir}/settings.json" ]; then
		{
			echo "{"
			echo "  \"files.exclude\": {"
			echo "    \"**/*.vscode/\": true,"
			echo "    \"**/*node_modules/\": true,"
			echo "    \"**/*yarn.lock\": true,"
			echo "    \"**/*package-lock.json\": true,"
			echo "    \"**/*package.json\": true,"
			echo "    \"**/*.env\": true,"
			echo "    \"**/*sanity.json\": true,"
			echo "    \"**/*lerna.json\": true,"
			echo "    \"**/*netlify.toml\": true,"
			echo "    \"**/*gulpfile.js\": true,"
			echo "    \"**/*README*.md\": true,"
			echo "    \"**/*readme*.txt\": true,"
			echo "    \"**/*humans.txt\": true,"
			echo "    \"**/*robots.txt\": true,"
			echo "    \"**/*.gitignore\": true,"
			echo "    \"**/*.gitkeep\": true,"
			echo "    \"**/*.jshintignore\": true,"
			echo "    \"**/*.eslintignore\": true,"
			echo "    \"**/*.eslintrc.js\": true,"
			echo "    \"**/*.prettierrc\": true,"
			echo "    \"**/*.sass-lint.yml\": true,"
			echo "    \"**/*.editorconfig\": true,"
			echo "    \"**/*.stylishcolors\": true,"
			echo "    \"**/*.pug-lintrc\": true,"
			echo "    \"**/*languages/\": true,"
			echo "    \"**/*LICENSE*\": true,"
			echo "    \"*.log\": true,"
			echo "    \"**/*.git/\": true,"
			echo "    \"**/*.ico\": true,"
			echo "    \"**/*.png\": true,"
			echo "    \"**/*.jpg\": true"
			echo "  }"
			echo "}"
		} >> "${dir}/settings.json"
	fi

	# Open file in editor
	editor "${dir}/settings.json"
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


# #####################################
# Noise
# #####################################
noise () {
	sounds=(
		"Basso"
		"Blow"
		"Bottle"
		"Frog"
		"Funk"
		"Glass"
		"Hero"
		"Morse"
		"Ping"
		"Pop"
		"Purr"
		"Sosumi"
		"Submarine"
		"Tink"
	)
	if [[ -z "$1" || "$1" == "-h" ]]; then
		echo "Play a system alert sound by passing in a sound from the below list as the option:"
		for sound in "${sounds[@]}"
		do
			echo "$sound"
		done
		return
	fi

	if [[ "${sounds[@]}" =~ "${1}" ]]; then
		echo "$1 matches"
		afplay "/System/Library/Sounds/$1.aiff"
	else
		echo "This doesn't match one of the alert sounds:"
		noise -h
	fi

}


# #####################################
# Create a "Scratch" file for testing something
# #####################################

scratch() {
	base_file="$HOME/Desktop/scratch"
	type="$1"

	_create_html() {
		{
			echo "<!doctype html>"
			echo "<html lang=\"en\">"
			echo "<head>"
			echo "	<meta charset=\"utf-8\">"
			echo "	<title>Scratch File</title>"
			echo "	<meta name=\"description\" content=\"\">"
			echo "	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
			echo "</head>"
			echo ""
			echo "<body>"
			echo "	<h1>This is a Scratch File</h1>"
			echo ""
			echo "</body>"
			echo ""
			echo "</html>"
		} >> "$base_file.$type"
	}

	_create_sh() {
		{
			echo "#!/bin/bash"
			echo ""
			echo "echo \"hello world!\""
		} >> "$base_file.$type"
	}

	if [[ -z "$1" ]]; then
		echo "Create a scratch file for testings something in your code editor"
		return
	fi

	if [[ ! -f "$base_file.$type" ]]; then

		if [[ "$type" == "html" ]]; then
			_create_html

		elif [[ "$type" == "sh" ]]; then
			_create_sh

		else
			touch "$base_file.$type"
		fi

		editor "$base_file.$type"

	else
		editor "$base_file.$type"
	fi

}