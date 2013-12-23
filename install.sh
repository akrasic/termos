#!/bin/bash
#
#	Install and configure working environment
#
#	- Vim configuration
#	- Powerline fonts
#	- Powerline-shell for Bash
#

if [ "$SHELL" != "/bin/bash" ]; then
	echo "This is intended for Bash shell!"
	exit 1
fi

## Define repositories to download from
sources=(
  https://github.com/milkbikis/powerline-shell.git
  https://github.com/Lokaltog/powerline-fonts
  https://github.com/akrasic/vim.git
)

## Dependencies for installation / successful environment
##
depends=(
  vim
  git
  fc-cache
  python
)

function check_depends() {
  err=0
  for pkg in "${depends[@]}"; do
    which $pkg > /dev/null 2>&1
    if [ "$?" -gt "0" ]; then
      echo "Package not found: $pkg"
      err=1
    fi
  done

  if [ "$err" -eq "1" ]; then
    exit 1
  fi
}

# Download repository using git
function download_git() {
  echo -e "Cloning git repo: $1"
  git clone $1 > /dev/null 2>&1
}

## Bashrc / aliases installation
function bash_install() {
  echo "======================================================================="
  echo -e "\t Bash configuration"
  echo "======================================================================="

  if [ -f  "$HOME/.bashrc" ]; then
    mv $HOME/.bashrc $HOME/.bashrc.old
  fi
  if [ -f  "$HOME/.bash_aliases" ]; then
    mv $HOME/.bash_aliases $HOME/.bash_aliases.old
  fi

  if [ -L "$HOME/.bashrc" ]; then
    rm -f $HOME/.bashrc
  fi
  if [ -L "$HOME/.bash_aliases" ]; then
    rm -fv $HOME/.bash_aliases
  fi

  ln -s $PWD/bash/bashrc $HOME/.bashrc
  ln -s $PWD/bash/aliases $HOME/.bash_aliases
}

# Public - Install screenrc
function screenrc_install() {
  echo "======================================================================="
  echo -e "\t Screen configuration"
  echo "======================================================================="
  if [ -L "$HOME/.screenrc" ]; then
    rm -f $HOME/.screenrc
  fi

  ln -s $PWD/screen/screenrc $HOME/.screenrc
}
# Public - Helper function to install repositores
function shell_install() {
  if [ ! -d "$HOME/bin/" ]; then
    mkdir $HOME/bin
  fi
  cd $HOME/bin

  gitrepo=$(echo ${1##*/}|cut -d. -f1)

  echo "======================================================================="
  echo -e "\tInstalling $gitrepo"
  echo "======================================================================="

  download_git $1
  cd $gitrepo

  case $gitrepo in
    powerline-fonts)
      if [ ! -d "$HOME/.fonts/" ]; then
        mkdir ~/.fonts
      fi
      cp -pf DejaVuSansMono/*.ttf ~/.fonts/
      fc-cache -vf ~/.fonts/
      ;;
    powerline-shell)
      ./install.py
      ;;
    vim)
      bash ./bundle.sh install
      ;;
  esac
  echo ""
}

# Check dependencies
check_depends

##------------------------------------
## Install Bash conf and aliases
##------------------------------------
bash_install

##------------------------------------
## Install stuff from repositories
##------------------------------------
for source_repo in "${sources[@]}"
do
  shell_install $source_repo
done

if [ "$?" -eq "0" ]; then
  echo "Installation complete!"
  echo "Please configure your terminal emulator to use the Powerline fonts"
  echo "and then you're all set."
else
  echo "Installation failed for some unknown reason. Oh, well.."
fi
