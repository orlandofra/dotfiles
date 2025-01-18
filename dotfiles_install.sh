#!/bin/bash
### svergina la macchina ###

cleanup() {
	[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
}
trap 'cleanup; exit 1' SIGINT
trap cleanup EXIT

confirm() {
	if [ ! -t 0 ]; then
		return 0
	fi

	local response
	local prompt="${1}"

	read -p "$prompt [y/N]" response

	response=$(echo "${response:-n}" | tr '[:upper:]' '[:lower:]')

	if [[ "$response" == "y" || "$response" == "yes" \
			|| "$response" == "s" || "$response" == "si" ]]; then
		return 0
	else
		return 1
	fi
}


install_scripts(){
	confirm "Installare il gli scripts?? in ${HOME}?" || continue

	mkdir -p $HOME/.local/Scripts
	cp -r $TEMP_DIR/dotfiles/Scripts $HOME/.local/Scripts
}

DOTFILES=(
	".bash_aliases"
	".bash_funcs"
	".bashrc"
	".gitignore"
	".profile"
	".tmux.conf"
	".vimrc"
)

DOTDIRS=(
	".vim"
	".imapfilter"
)

PACKAGES=(
	"tmux"
	"vim-gtk3"
	"feh"
	"sox"
	"mutt"
	"yt-dlp"
	"imagemagick"
	"ffmpeg"
	"mpv"
	"openvpn"
	"openssh-client"
	"libpoppler-glib-dev"
	"libcairo2-dev"
)

install_packages(){
	sudo apt update
	sudo apt install -y "${PACKAGES[@]}"
}


TEMP_DIR=$(mktemp -d)
[ -d "$TEMP_DIR" ] || { echo "creazione di dir temporanea non riuscita"; exit 1; }


pushd $TEMP_DIR
	git clone --recurse-submodules https://github.com/orlandofra/dotfiles.git || \
		{ echo "git error"; exit 1; }

popd

for file in "${DOTFILES[@]}";
do
	confirm "Installare il file ${file} in ${HOME}?" || continue

	cp $TEMP_DIR/dotfiles/${file} $HOME/
done

for dir in "${DOTDIRS[@]}";
do
	confirm "Installare la directory ${dir} in ${HOME}?" || continue

	suffix=BAK$RANDOM
	[ -d "$HOME/${dir}" ] && mv $HOME/${dir} $HOME/${dir}.${suffix}
	cp -r $TEMP_DIR/dotfiles/${dir} $HOME/

	confirm "eliminare backup della vecchia ${dir} in $HOME/${dir}.${suffix}?" && \
		rm -rf $HOME/${dir}.${suffix}
done

install_scripts

rm -rf $TEMP_DIR
echo -e "\033[0;32m" # green
echo i dotfiles sono stati installati sei pronto ad utilizzare questa macchina da vero terrorista
echo -e "\033[0m" # reset

[ -f ~/.gitignore ] && git config --global core.excludesfile ~/.gitignore

confirm "installare pachetti di uso comune?" && install_packages
