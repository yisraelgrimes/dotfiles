#! /usr/bin/zsh

# #####################################
# Get the utilities
# #####################################
if [ -f "./utils.sh" ]; then
	source "./utils.sh"
else
	echo "There's a problem connecting to the utilities file"
fi


# #####################################
# Do the things
# #####################################

# Persist sudo-mode
keep_alive


# Install Other Apps
ask_yn "Install you other apps using `homebrew` ?"
if [[ $REPLY =~ ^[y]$ ]]; then
	include "./apps/other_apps.sh"
	success "Other apps are installed"
fi