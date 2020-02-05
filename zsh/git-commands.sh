#! /usr/bin/zsh
# shellcheck disable=SC1090
# shellcheck disable=SC2120
# shellcheck disable=SC2154
# #####################################


GITHUB_USERNAME=$(git config user.name)
GITHUB_EMAIL=$(git config user.email)


# Get the Current Working Branch from Git
cwb() {
	if [ -e .git ]; then
		cwb=$(git symbolic-ref --short HEAD)
		export cwb
		echo "Active branch is $cwb"
	else
		echo "Not a git repository."
	fi
}


# Commit and Push to previously assigned remote with (optional) message.
gitgo() {
	if [ ! "$*" ]; then
		message=Bump
	else
		message="$*"
	fi
	git add . && git commit -m "$message" && git push
}


# Destroy gh-pages branch (local and remote)
# TODO: Add test to make sure cwb isn't gh-pages
burn_ghpages() {
	git branch -D gh-pages
	git push -d origin gh-pages
}


init_ghpages() {
	# repo_name="$(basename "$PWD")"
	# Get the current branch
	cwb

	if [ ! -d _gh-pages ]; then
		mkdir _gh-pages
		cp .gitignore _gh-pages/
		cp README.md _gh-pages/
	fi

	git checkout --orphan gh-pages
	git rm -rf .

	git checkout "$cwb" -- _gh-pages

	shopt -s dotglob
	mv _gh-pages/* .
	rm -rf _gh-pages
	git add . && git commit -m "Init Pages" && git push origin gh-pages
	# Go back to the current branch
	git checkout "$cwb"

}


# Updates gh-pages branch with content from '_gh-pages'
# Optional commit message or defaults to 'Bump'
# Optional choice of branch to source from or defaults to 'master'
ghpages() {

	# Make sure current branch is updated
	gitgo

	# Get the current branch
	cwb

	git checkout gh-pages

	shopt -s extglob
	# rm -rf !(.git)

	git checkout "$cwb" -- _gh-pages
	shopt -s dotglob
	mv _gh-pages/* .
	rm -rf _gh-pages


	if [ ! "$1" ]; then message="Bump Pages"; fi
	git add . && git commit -m "$message"

	if [ "$2" == "set" ]; then
		git push --set-upstream origin gh-pages
	else
		git push
	fi

	git checkout "$cwb"
}


# Create new local and remote repo
github_new() {
	# Input
	echo "What do you want to name your project folder?"
	read -r pr_dir
	if [ -d "$pr_dir" ]; then echo "Directory already exists."; return; fi

	echo "Do you want to make this project private? (y/n)"
	read -r access

	echo "Do you want to set up Github Pages?? (y/n)"
	read -r ghpages

	echo "Write something for your project readme file."
	read -r readme_desc

	echo "Write a project description for Github."
	read -r pr_desc
	########################

	mkdir "$pr_dir"
	cd "$pr_dir" || return

	# Download Gitignore from Gist
	curl -o .gitignore git.io/v7bYQ

	# Create the readme file
	echo "$readme_desc" >> README.md

	# Set up git local and remote
	git init
	git add .
	git commit -m "Init Commit."

	# Set URL that will write to the Repo description
	if [ "$ghpages" == "y" ]; then
		pr_url=https://${GITHUB_USERNAME}.github.io/${pr_dir}
	else
		pr_url=https://github.com/${GITHUB_USERNAME}/${pr_dir}
	fi

	# Create Remote with HUB CLI and (optionally) set as private
	if [ "$access" == "y" ]; then
		git create -p -d "$pr_desc" -h "$pr_url"
	else
		git create -d "$pr_desc" -h "$pr_url"
	fi
	git push origin master

	# Setup Github Pages
	if [ "$ghpages" == "y" ]; then
		init_ghpages
		# Open Gh-pages in Browser
		open https://"$GITHUB_USERNAME".github.io/"$pr_dir"
	fi

	# Open repo in browser and EDITOR
	open https://github.com/"$GITHUB_USERNAME"/"$pr_dir"

	echo "Done. Would you like to open the directory in $EDITOR? (y/n)"
	read -r rsp_editor
	if [ "$rsp_editor" == "y" ]; then open -a "$EDITOR" .; fi
}



# Gets the parent of the cwd
# parentdir="$(basename "$(dirname "$dir")")"
