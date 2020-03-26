#! /usr/bin/zsh
#
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# #####################################

# If file is found, then source it
include() { [[ -f "$1" ]] && source "$1"; }

# #####################################
# Setup $PATH
# #####################################

# VSCode command line path
CODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

export PATH="$PATH:$CODE"

# #####################################
# zsh options
# #####################################

# Path to your oh-my-zsh installation.
export ZSH="/Users/yis/.oh-my-zsh"

# Set name of the oh-my-zsh theme to load
# themes: https://t.ly/MMx06
# themes: robbyrussell, ys, sunrise, pygmalion
ZSH_THEME="simple"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-syntax-highlighting
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Use Case Insensitive Globbing
setopt NO_CASE_GLOB

# Auto CD to path. Removes the need for `cd` in the command
setopt AUTO_CD

# Save shell history upon exiting shell
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history

# Add timestamp (in unix epoch time) to shell history
setopt EXTENDED_HISTORY

# Only save 3000 commands in shell history
SAVEHIST=3000

# Only save 200 commands in current shell session
HISTSIZE=200

# Share shell history across multiple zsh sessions
setopt SHARE_HISTORY
# Append shell history instead of overwriting it
setopt APPEND_HISTORY

# Add commands to history file as they are entered, not at shell exit
setopt INC_APPEND_HISTORY

# Remove blank lines from shell history file
setopt HIST_REDUCE_BLANKS

# Verify the history option command (`!!`) before running it
setopt HIST_VERIFY

# Let zsh offer suggestions when I enter a mistake
# [nyae]
#   n: execute command as typed
#   y: accept and execute suggested command
#   a: abort command and do nothing
#   e: return to the prompt to continue editing
setopt CORRECT
setopt CORRECT_ALL

# #####################################
# Completion
# #####################################

# case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# Initialize zsh completion system. @see: t.ly/7J6B2
autoload -Uz compinit && compinit

# #####################################
# File Paths
# #####################################

# Where synced files are stored in Dropbox
SYNC_DIR="$HOME/Dropbox/jibesync"

# #####################################
# Load Files
# #####################################
include "$HOME/_dotfiles/zsh/git-commands.sh"
include "$HOME/_dotfiles/zsh/wip.sh"

# #####################################
# Shortcuts & Variables
# #####################################

# Get the computer name as a variable
MACNAME="$(networksetup -getcomputername)"

# Clear terminal window
alias c="clear"

# My other mac's $HOME
OTHER_MAC="/Volumes/yis"

# Reload Shell
alias reshell="source $ZDOTDIR/.zshrc"

# Hide/show desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Get the date in `YYMMDD` format
shortdate() {
	date +"%y%m%d"
}

# Get the time
TIME="$(date +'%H%M%S')"
shorttime() {
	date +"%H%M%S"
}

# Copy the current directory path to the clipboard
alias copypath="pwd|pbcopy"

# #####################################
# Working with Files
# #####################################

# Go to Grandparent Directory
alias ...="cd ../../"

# List files in dir
# A - include hidden files
# F - Include "/" for folders
# G - use Color
alias ls="ls -AFG"

# List files in dir
# A - include hidden files
# F - Include "/" for folders
# G - use Color
alias lsa="ls -AFG"

# Do stuff above and:
# l - list permissions
alias lsl="ls -AFGl"

# Do the stuff above and:
# sk - print size in kilobytes
# S  - Sort by size
# r  - Reverse the sort so largest is on top
alias lss="ls -AFGskSrl"

# cd to Desktop
alias desk="cd $HOME/Desktop"

# cd to iCloud Drive
ICLOUD=$HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs

# `o` with no arguments opens the current terminal directory,
# otherwise opens the given location
o() { if [ $# -eq 0 ]; then open .; else open "$@"; fi; }

# Make a directory and cd into it
mkdircd() { mkdir "$*" && cd "$*" || return; }

# Remove node_modules and _rsync-trash directories
declutter() {
	cwd=$(pwd)

	if [ "$1" == "-Y" ]; then
		cd "$HOME/Git" || return
		# Remove Node Modules
		if [ "$2" == "node" ]; then
			find . -name "node_modules" -prune -exec rm -rf '{}' +
		# Remove Rsync Trash
		elif [ "$2" == "rsync" ]; then
			find . -name "_rsync-trash" -prune -exec rm -rf '{}' +
		# Remove Node Modules and Rsync Trash
		else
			find . -name "node_modules" -prune -exec rm -rf '{}' +
			find . -name "_rsync-trash" -prune -exec rm -rf '{}' +
		fi
		cd "$cwd" || return
	else
		# Print help-info by default
		echo "this command will deletes 'node_modules' and '_rsync-trash' directories in $HOME/Git"
		echo "If you want to do this, run the command again with '-Y' flag."
		echo "Ex: <declutter -Y>"
		echo "Options"
		echo "node:   remove */node_modules/"
		echo "rsync:  remove */_rsync-trash/"
		echo "all:    (default option) - same as running both options"
	fi
}

# Rsync directory but exclude node_modules/
sync-node() {
	export src="$1"
	export dest="$2"

	if [[ "$src" == "--help" ]]; then
		echo "<arg 1>  - source project directory"
		echo "<arg 2>  - destination project PARENT directory"
		echo "<on run> - If there are differences between the project directories, then a directory called '_rsync-trash' will be created in the Parent directory of the destination project where all changed files from destination will be stored."
	elif [ ! -d "$src" ]; then
		echo "$src cannot be found. Exiting..."
		return
	elif [ ! -d "$dest" ]; then
		echo "$dest cannot be found. Exiting..."
	else
		rsync -avz --progress --exclude="node_modules/" --delete --backup --backup-dir="$2/_rsync-trash/$(shortdate)-$(shorttime)" "$1" "$2"

	fi
	unset src dest
}

# #####################################
# Apps & Command-Line Tools
# #####################################

# Plistbuddy CLI
alias pbuddy="/usr/libexec/PlistBuddy"

# Shorcut for 'brew cask'
alias cask="brew cask"

# TheFuck
eval "$(thefuck --alias)"

# Use the Hub CLI instead of the Standard Git CLI
alias git=hub

# Gulp alias
alias g=gulp

# Set Preferred Code Editor
EDITOR="code"

# Set Preferred Git Client
GITCLIENT="GitKraken"

# Docker CLI Aliases
alias d="docker"
alias dcontainer="docker container"
alias dimage="docker image"
alias dcompose="docker-compose"
alias dcls="docker container ls --format 'table {{.ID}}\t⎥ {{.Image}}\t⎥ {{.Names}}'"
alias dclsa="docker container ls -a --format 'table {{.ID}}\t⎥ {{.Image}}\t⎥ {{.Names}}'"
alias dclsap="docker container ls -a --format 'table {{.ID}}\t⎥ {{.Image}}\t⎥ {{.Command}}\t⎥ {{.RunningFor}}\t⎥ {{.Status}}\t⎥ {{.Ports}}\t⎥ {{.Names}}'"

# Code Editor: Default opens the current directory, otherwise opens the given path
# VSCode
vs() { if [ $# -eq 0 ]; then code .; else code "$@"; fi; }
# Default Editor
editor() { if [ $# -eq 0 ]; then $EDITOR .; else $EDITOR "$@"; fi; }

# GitClient: default opens current dir in gitkraken, else opens the given path
kracken() {
	if [ "$*" == "--help" ]; then
		echo "Opens the current or supplied directory in GitKracken (if it is a git repo)"
		echo "<option>  - Path to directory"
		return
	fi
	if [ "$*" ]; then
		repopath="$*"
	else
		repopath="."
	fi
	# If the directory is NOT a git repo, don't do anything
	if [ ! -d "$repopath/.git" ]; then
		echo "This is not a git repo"
		return
	else
		cd "$repopath" || return
		open -na $GITCLIENT --args -p "$(PWD)"
	fi
	unset repopath
}

# #####################################
# Toggle system prefs & Controls
# #####################################

# Computer controls
stayawake() {
	if [ "$*" == "system" ]; then
		# Keep System from Going to Sleep
		"caffeinate -i"

	elif [ "$*" == "screen" ]; then
		# Keep Screen from Going to Sleep
		"caffeinate -d"

	elif [ "$*" == "disk" ]; then
		# Keep Disk from Going Idle
		"caffeinate -m"

	elif [ "$*" == "charging" ]; then
		# Keep System from Going to Sleep (while on power)
		"caffeinate -s"

	elif [ "$*" == "3hours" ]; then
		# Keep System from Going to Sleep for 3 hours
		"caffeinate -t 10800"

	else
		echo "Keep the computer awake using these options:"
		echo "<system>   : Keeps System from Going to Sleep"
		echo "<screen>   : Keeps Screen from Going to Sleep"
		echo "<disk>     : Keeps Disk from Going Idle"
		echo "<charging> : Keeps System from Going to Sleep while charging"
		echo "<3hours>   : Keeps System from Going to Sleep for 3 hours"
	fi
}

# Toggle auto capitalization as it’s annoying when typing code
autocap() {
	if [ "$*" == "off" ]; then
		defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
	else
		defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
	fi
}

# Toggle smart dashes as they’re annoying when typing code
smartdash() {
	if [ "$*" == "off" ]; then
		defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
	else
		defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool true
	fi
}

# Toggle smart dashes as they’re annoying when typing code
smartquote() {
	if [ "$*" == "off" ]; then
		defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
	else
		defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool true
	fi
}

# Toggle auto-correct spelling
autocorrect() {
	if [ "$*" == "off" ]; then
		defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
	else
		defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true
	fi
}

# Toggle automatic period substitution
autoperiod() {
	if [ "$*" == "off" ]; then
		defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
	else
		defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true
	fi
}

# #####################################
# Some other helpful things
# #####################################

# Open ZSH Files
openzsh() {
	editor "$ZDOTDIR/.zshrc"
	editor "$ZDOTDIR/wip.sh"
	editor "$ZDOTDIR/git-commands.sh"
	editor "$SYNC_DIR/manual_sync/tacos"
}

# Check open ports
# https://wilsonmar.github.io/ports-open/
# https://stackoverflow.com/questions/12397175/how-do-i-close-an-open-port-from-the-terminal-on-the-mac
openports() {
	if [ "$*" == "--help" ]; then
		echo "This function prints all to the currently open ports"
		echo "Format:"
		echo "Command | Pid | User | FD | Type | Device | Size | Node"
	else
		echo "Command | Pid | User | FD | Type | Device | Size | Node"
		echo "======="
		lsof -nP +c 15 | grep LISTEN

		# Check what is listening on a specific port:
		# netstat | grep 8080
	fi
}

# Install new version of node and migrate previous packages
install_node() {
	if [ "$1" == "--help" ] || ! [ "$1" ]; then
		echo "Installs a new version of node while reinstalling packages in your system for the new version."
		echo "Options:"
		echo "  1) <node version> -- required"
		echo "  2) <version to migrate packages from> -- optional"

	else
		newVersion="$1"
		migrateFrom="node"
		if [ "$2" ]; then
			migrateFrom="$2"
		fi
		nvm install "$newVersion" --reinstall-packages-from="$migrateFrom"
		unset newVersion migrateFrom
	fi
}

# Enable Dev Mode for Sketch.app
sketch_dev() {
	if [ "$*" == "--help" ]; then
		echo "This function enables dev-mode for sketch.app (for plugin dev)"
		echo "Options: on, off"
		echo "Use 'on' to keep sketch from caching plugins (for plugin dev). Use 'off' to go back to normal."

	else
		if [ "$*" == "on" ]; then
			defaults write ~/Library/Preferences/com.bohemiancoding.sketch3.plist AlwaysReloadScript -bool YES
		fi
		if [ "$*" == "off" ]; then
			defaults write ~/Library/Preferences/com.bohemiancoding.sketch3.plist AlwaysReloadScript -bool NO
		fi
	fi
}

rip_audio() {
	url="$1"
	format="mp3"
	if [ "$2" ]; then format="$2"; fi

	if [ "$1" == "--help" ]; then
		echo "This function is used to download the audio from a video file from a url (like YouTube)"
		echo "The file is then saved to the Desktop"
		echo "Example:"
		echo "get-audio <full/url> <format>"
		echo "'format' is optional and defaults to .mp3"
	else
		cwd=$(pwd)
		cd "$HOME/Desktop" || return
		youtube-dl --extract-audio --audio-format "$format" "$url"
		cd $cwd
	fi

	unset cwd
}

# Play Sounds:
# alias taskready='afplay /System/Library/Sounds/Hero.aiff'
# Basso.aiff
# Frog.aiff
# Hero.aiff
# Pop.aiff
# Submarine.aiff
# Blow.aiff
# Funk.aiff
# Morse.aiff
# Purr.aiff
# Tink.aiff
# Bottle.aiff
# Glass.aiff
# Ping.aiff
# Sosumi.aiff
