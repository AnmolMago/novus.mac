#!/bin/bash

cd .
source ./lib/util

if [[ "$#" -gt 1 ]]; then
  log_error "Incorrect number of arguments."
  run_help
  exit
elif [[ "$1" != "install" ]]; then
  run_help
  exit
fi

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install command line tools
if ! cmd_exists "xcode-select" || ! xpath=$( xcode-select --print-path ) || ! test -d "${xpath}" || ! test -x "${xpath}"; then
  log_header "Installing xcode command line tools..."
  xcode-select --install
fi

# Install brew
if ! cmd_exists 'brew'; then
  log_header "Installing Homebrew..."
  sudo rm -rf "/usr/local/Homebrew" 
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Check for git
if ! cmd_exists 'git'; then
  log_header "Installing Git..."
  brew install git
fi

if ! is_git_repo; then
  log_header "Initializing git repository"
  GIT_REMOTE="https://github.com/AnmolMago/novus.mac.git"

  git init
  git remote add origin ${GIT_REMOTE}
  git fetch origin master
  git reset --hard FETCH_HEAD
  git clean -fd
fi

log_header "Syncing with git repository"
git pull --rebase origin master
git submodule update --recursive --init --quiet

if confirm "Reset OSX Defaults"; then
  log_header "Setting macOS defaults..."
  bash ./lib/osxdefaults
fi


if confirm "Reset Git config"; then
  git config --global diff.plist.textconv "plutil -convert xml1 -o -"
  log_header "Installing git configuration..."
  novus_link "git/gitattributes"  ".gitattributes"
  novus_link "git/gitignore"      ".gitignore"
  novus_link "git/gitconfig"      ".gitconfig"
fi

if confirm "Reinstall brew cli packages"; then
log_header "Installing brew packages..."
declare -a brew_formulae=("go" "cmake" "tree" "zsh" "zsh-completions" "bash-completion"
                          "python3" "bash-completion" "git-crypt" "hub" "yarn")

brew install $( printf "%s " "${brew_formulae[@]}" )
brew upgrade
fi

if confirm "Reinstall brew cask apps and fonts"; then

  log_header "Installing cask apps..."
  brew tap homebrew/cask-drivers
  declare -a brew_cask_formulae=("iterm2" "visual-studio-code" "github" "tunnelbear" "lastpass"
                                "google-chrome" "sketch" "spotify" "soundflower" "soundflowerbed"
                                "adobe-creative-cloud" "microsoft-office" "cyberduck"
                                
                                "logitech-options" "nvidia-web-driver"
                                )
  brew cask install $( printf "%s " "${brew_cask_formulae[@]}" )

  log_header "Installing fonts..."
  declare -a brew_fonts=("font-robotomono-nerd-font" "font-roboto" "font-roboto-slab"
                        "font-roboto-condensed" "font-roboto-mono")
  brew tap homebrew/cask-fonts
  brew cask install $( printf "%s " "${brew_fonts[@]}" )
fi

if confirm "Install yarn packages (react)"; then
  log_header "Installing yarn packages..."
  declare -a yarn_formulae=("react-native-cli" "react-native" "react-devtools")

  yarn global add $( printf "%s " "${yarn_formulae[@]}" )
fi

if confirm "Reset zsh"; then
  log_header "Installing zsh and its configuration..."
  sudo rm -rf "/usr/local/share/zsh" "$HOME/.oh-my-zsh"
  osascript -e 'tell application "Terminal" to do script "sh -c \"$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\""'
  log_header "See other terminal window to complete zsh window."
  sleep 1s
  # Install powerlevel9k 
  [ ! -d "${HOME}/.oh-my-zsh/themes/powerlevel9k" ] && git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

  # Install zsh-autosuggesstions
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  novus_link "shell/zshrc"         ".zshrc"
fi


if confirm "Reset bash settings"; then
  novus_link "shell/bashrc"        ".bashrc"
  novus_link "shell/bash_profile"  ".bash_profile"
fi


if confirm "Reset vs code"; then
  log_header "Installing VS Code packages and settings..."
  # Install VS Code settings
  code --install-extension shan.code-settings-sync

  prompt "Please use vscode to Sync via extension. Sign in to GitHub and select id f950324ee59d97b001b0f442ba534dd4. Reload Window"
fi
prompt "Manually install iTerm colors and font from apps/iTerm. Set theme to minimal."

log_success "Completed installation of new macbook. Restart to activate all settings."

if confirm "REMOVE PASSWORD LENGTH RESTRICTION??????????? 1/3"; then
if confirm "REMOVE PASSWORD LENGTH RESTRICTION??????????? 2/3"; then
if confirm "REMOVE PASSWORD LENGTH RESTRICTION??????????? 3/3"; then
pwpolicy -clearaccountpolicies
fi
fi
fi

if confirm "Restart"; then
  osascript -e 'tell app "loginwindow" to «event aevtrrst»'
fi
