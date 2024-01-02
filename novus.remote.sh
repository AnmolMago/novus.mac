#!/bin/bash

prompt() {
  read -p "${1}. Press enter to continue."
}

confirm() {
  read -p "${1}? [y/N]" response
  case "$response" in
    [yY][eE][sS]|[yY])
      true
      ;;
    *)
      false
      ;;
  esac
}

cmd_exists() {
  if [ $(type -P $1) ]; then
    true
  else
    false
  fi
}

log_header() {
  printf "$(tput setaf 9)%s$(tput sgr0)\n" "$@"
}

NOVUS_DIR="${HOME}/novus.mac"

if cmd_exists '/opt/homebrew/bin/brew'; then
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> "${HOME}/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
# Install brew
if ! cmd_exists 'brew'; then
  log_header "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Check for git
if ! cmd_exists 'git'; then
  log_header "Installing Git..."
  brew install git
fi

if confirm 'Setup git repo'; then

  if [ -d $NOVUS_DIR ]; then rm -rf $NOVUS_DIR; fi

  mkdir $NOVUS_DIR
  cd $NOVUS_DIR

  ssh-keygen -t rsa -b 4096 -C "anmolmago@gmail.com" -N "" -f $HOME/.ssh/id_rsa
  ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
  cat ~/.ssh/id_rsa.pub
  prompt "Please put the previous output here: https://github.com/settings/ssh/new"

  log_header "Initializing git repository"
  GIT_REMOTE="git@github.com:AnmolMago/novus.mac.git"

  git config --global init.defaultBranch dev
  git config user.email "anmolmago@gmail.com"

  git init
  git remote add origin ${GIT_REMOTE}
  git pull origin dev
  git branch --set-upstream-to origin/dev
  git clean -fd
fi

if confirm 'Ready to install'; then
  source $NOVUS_DIR/novus.mac.sh install
fi
