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

# Install NPM Apps
# ask_yn "Install Node apps with NPM?"
# if [[ $REPLY =~ ^[y]$ ]]; then
# 	npm install -g gulp
# 	npm install -g gatsby-cli
# 	success "Node apps installed"
# fi


# Setup .gitconfig
ask_yn "Set up .gitconfig?"
if [[ $REPLY =~ ^[y]$ ]]; then
	backup_and_remove "$DOTDIR/zsh/.gitconfig"
	ln -s "$DOTDIR/zsh/.gitconfig" "$HOME"
	success "gitconfig added to home directory"
fi


# Remove default login message
ask_yn "Add hushlogin to home directory?"
if [[ $REPLY =~ ^[y]$ ]]; then
	if [ ! -f "$HOME/.hushlogin" ]; then
		touch "$HOME/.hushlogin"
	fi
fi


# Set up ZSH
ask_yn "Set up zsh?"
if [[ $REPLY =~ ^[y]$ ]]; then
	# Symlink zsh environment file to home
	doing "Setting up .zshenv file"
	backup_and_remove "$DOTDIR/zsh/.zshenv"
	ln -s "$DOTDIR/zsh/.zshenv" "$HOME"

	# Install Oh-My-Zsh
	doing "Insalling oh-my-zsh"
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

	# Backup default .zshrc file
	move_to_backup "$HOME/.zshrc"

	# Install zsh syntax-highlighting plugin
	doing "Installing zsh-syntax-highlighting plugin"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

	# Install zsh auto-suggestions plugin
	doing "Installing zsh-autosuggestions plugin"
	git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

	# Symlink customizations back to oh-my-zsh
	move_to_backup "$HOME/.oh-my-zsh/custom"
	ln -s "$DOTDIR/zsh/oh-my-zsh/custom" "$HOME/.oh-my-zsh/"

	# Reload shell
	source "$DOTDIR/zsh/.zshrc"

	success "zsh is ready to go!"
fi


# Setup Git project directories
ask_yn "Set up Git project directories?"
if [[ $REPLY =~ ^[y]$ ]]; then
	if [ ! -d "$HOME/Git" ]; then mkdir "$HOME/Git"; fi
	if [ ! -d "$HOME/Git/cookbook" ]; then mkdir "$HOME/Git/cookbook"; fi
	if [ ! -d "$HOME/Git/design" ]; then mkdir "$HOME/Git/design"; fi
	if [ ! -d "$HOME/Git/projects" ]; then mkdir "$HOME/Git/projects"; fi
	if [ ! -d "$HOME/Git/projects-personal" ]; then mkdir "$HOME/Git/projects-personal"; fi
	if [ ! -d "$HOME/Git/resources" ]; then mkdir "$HOME/Git/resources"; fi
	if [ ! -d "$HOME/Git/resources-personal" ]; then mkdir "$HOME/Git/resources-personal"; fi
	success "Git directories added"
fi


# Sketch
ask_yn "Set up Sketch Resources? Make sure you have already opened Sketch and registered the app."
if [[ $REPLY =~ ^[y]$ ]]; then
	local_sketch_dir="$HOME/Library/Application Support/com.bohemiancoding.sketch3"
	sync_sketch_dir="$SYNC_DIR/files/Users/yis/Library/Application Support/com.bohemiancoding.sketch3"

	if [ ! -d "$HOME/Git/design" ]; then mkdir "$HOME/Git/design"; fi

	# Templates
	if [ ! -d "$HOME/Git/design/sketch-templates" ]; then
		doing "Cloning your templates Library"
		git clone https://gitlab.com/workwithizzi/cookbook/sketch-templates.git "$HOME/Git/design/sketch-templates"
	fi
	if [ -d "$local_sketch_dir/Templates" ]; then
		doing "Symlinking templates Library"
		rm -rf "$local_sketch_dir/Templates"
		ln -s "$HOME/Git/design/sketch-templates" "$local_sketch_dir/Templates"
	fi

	# Plugins
	if [ -d "$local_sketch_dir/Plugins" ]; then
		rm -rf "$local_sketch_dir/Plugins"
	fi
	if [ -d "$HOME/Dropbox/sketch-plugins/Plugins" ]; then
		ln -s "$HOME/Dropbox/sketch-plugins/Plugins" "$local_sketch_dir/Plugins"
	fi

	# Midnight Plugin
	if [ -d "$local_sketch_dir/Midnight" ]; then
		rm -rf "$local_sketch_dir/Midnight"
	fi
	if [ -d "$sync_sketch_dir/Midnight" ]; then
		ln -s "$sync_sketch_dir/Midnight" "$local_sketch_dir/Midnight"
	fi

	# Panels
	if [ -d "$local_sketch_dir/Panels" ]; then
		rm -rf "$local_sketch_dir/Panels"
	fi
	if [ -d "$sync_sketch_dir/Panels" ]; then
		ln -s "$sync_sketch_dir/Panels" "$local_sketch_dir/Panels"
	fi

	# PluginsWarehouse
	if [ -d "$local_sketch_dir/PluginsWarehouse" ]; then
		rm -rf "$local_sketch_dir/PluginsWarehouse"
	fi
	if [ -d "$sync_sketch_dir/PluginsWarehouse" ]; then
		ln -s "$sync_sketch_dir/PluginsWarehouse" "$local_sketch_dir/PluginsWarehouse"
	fi

	# Runner
	if [ -d "$local_sketch_dir/Runner" ]; then
		rm -rf "$local_sketch_dir/Runner"
	fi
	if [ -d "$sync_sketch_dir/Runner" ]; then
		ln -s "$sync_sketch_dir/Runner" "$local_sketch_dir/Runner"
	fi
fi