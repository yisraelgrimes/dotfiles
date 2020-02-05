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


# Sync Music
say "Open iTunes and authorize your computer."
waiting "Don't forget to add your music back to your library."