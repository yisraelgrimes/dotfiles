#! /usr/bin/zsh

# #####################################
# Variables
# #####################################

# Dotfiles Remote Directory
DOTREMOTE="https://github.com/yisraelgrimes/dotfiles.git"

# Temporary directory for installer files
INSTALL_BACKUP="$HOME/_macos-install-backup"

# Dofiles directory location
DOTDIR="$HOME/_dotfiles"

# Location of all the installer files
INSTALL_DIR="$HOME/_dotfiles/install"

# Where synced files are stored in Dropbox
SYNC_DIR="$HOME/Dropbox/jibesync"

# Get the name of the mac
MACNAME="$(networksetup -getcomputername)"


# #####################################
# Interaction Shortcuts
# #####################################

# Output a line break to terminal
alias BR='echo -e "\n"'

# Print a title for sections
section_title() { echo "══╣ $* ╠══" }

# Output a message to user
say() { echo "$*"; BR; }

# Output that the system is "Doing" something
doing() { echo "🚀  ""$*"; BR; }

# Success feedback
success() { echo "🎉  ""$*"; BR; }

waiting() { read "REPLY?⏸  "" $* Press [return] to continue."; }
# waiting "Waiting for you to finish."

# Ask a yes/no/skip Question
ask_yn() { read "REPLY?❓  "" $* [y|n]  "}
# if [[ $REPLY =~ ^[y]$ ]]; then
# 	# yes
# elif [[ $REPLY =~ ^[n]$ ]]; then
# 	# no
# fi


# #####################################
# Functions
# #####################################

# Source file if exists
include() { if [ -f "$*" ]; then . "$*"; else return; fi }

# Move file to backup directory if it exists
move_to_backup() {
	# Prepend unix timestamp to filename
	filename="$(date +%s)-$(basename "$1")"
	# Create backup directory if it doesn't exits
	if [ ! -d $INSTALL_BACKUP ]; then mkdir $INSTALL_BACKUP; fi
	# Move file to backup directory
	if [ -e "$1" ]; then mv "$1" "$INSTALL_BACKUP/$filename"; fi
	}

remove() {
	if [ -e "$1" ]; then rm -rf "$1"; fi
}

backup_and_remove() {
	move_to_backup "$1"
	remove "$1"
}

# Ask for the administrator password upfront
# keep sudo active until exit
keep_alive() {
	say "Enter your admin password:"
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}