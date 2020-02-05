#! /usr/bin/zsh

# #####################################
# Get the utilities
# #####################################
if [[ -f "./utils.sh" ]]; then
	source "./utils.sh"
else
	echo "There's a problem connecting to the utilities file"
fi

# #####################################
# Do the things
# #####################################

# Persist sudo-mode
keep_alive


# doing "Installing Homebrew"
ask_yn "Install Homebrew?"
if [[ $REPLY =~ ^[y]$ ]]; then
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	success "Homebrew is installed"
fi

# Install Essential Apps
ask_yn "Install Core Apps using `homebrew` ?"
if [[ $REPLY =~ ^[y]$ ]]; then
	include "./apps/brewfile-other.sh"
	success "Core apps are installed"
fi

# Sync Dropbox
waiting "Sign-in to Dropbox and let it can sync. Continue once it's finished."
BR

# Import Fonts
ask_yn "Install default system fonts?"
if [[ $REPLY =~ ^[y]$ ]]; then
	rsync -avz "$SYNC_DIR/manual_sync/Fonts/*" "$HOME/Library/Fonts"
	success "Fonts installed"
fi

# Configure Manual Apps
ask_yn "Ready to manually set up your core apps?"
if [[ $REPLY =~ ^[y]$ ]]; then
	say "Sign in to the apps that have already installed."
	BR
	waiting "1Password"
	waiting "Chrome"
	waiting "Forklift (favorites are synced through iCloud)"
	waiting "Gitkraken"
	waiting "Alfred (preferences are in Dropbox"
	waiting "Unclutter (files are synced in Box, Notes are synced in Dropbox"
	waiting "Bartender"
	waiting "BetterTouchTool"
	waiting "Betterzip"
	waiting "Box-Sync"
	waiting "Iterm2"

	say "VS Code"
	say "Install the `Settings-Sync` extenstion"
	say "Gist ID is:"
	waiting "dd4c85d4695d606f53f47aa1b5f50735"
fi


# SSH files
ask_yn "Set up SSH keys from Dropbox?"
if [[ $REPLY =~ ^[y]$ ]]; then
	doing "syncing ssh files"
	backup_and_remove "$HOME/.ssh"
	# symlink directory
	if [[ "$MACNAME" == "yis-imac" ]]; then
		ln -s "$SYNC_DIR/manual_sync/ssh/imac/" "$HOME/.ssh"
	elif [[ "$MACNAME" == "yis-mbp" ]]; then
		ln -s "$SYNC_DIR/manual_sync/ssh/mbp/" "$HOME/.ssh"
	fi
	success "ssh files synced"
fi

# Clone the actual repo
ask_yn "Clone the dotfiles repo?"
if [[ $REPLY =~ ^[y]$ ]]; then
	cd "$HOME"
	move_to_backup "$DOTDIR"
	git clone "$DOTREMOTE" "$HOME/_dotfiles"
	cd "$INSTALL_DIR"
fi


say "To continue setting things up, run:"
say ". $INSTALL_DIR/two.sh"