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
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Update brew only once for the whole script
brew update
export HOMEBREW_NO_AUTO_UPDATE=1

# Check for git
if ! cmd_exists 'git'; then
  log_header "Installing Git..."
  brew install git
fi

if ! is_git_repo; then
  ssh-keygen -t rsa -b 4096 -C "anmolmago@gmail.com" -N "" -f $HOME/.ssh/id_rsa
  ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
  cat ~/.ssh/id_rsa.pub
  prompt "Please put the previous output here: https://github.com/settings/ssh/new"

  log_header "Initializing git repository"
  GIT_REMOTE="git@github.com:AnmolMago/novus.mac.git"

  git init
  git remote add origin ${GIT_REMOTE}
  git pull origin master
  git branch --set-upstream-to origin/master
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
  declare -a brew_formulae=("go" "cmake" "tree" "zsh-autosuggestions"  "zsh-completions" 
                            "zsh-syntax-highlighting" "python" "bash-completion" "git-crypt" "hub"
                            "postgresql" "rustup" "svn")

  brew install $( printf "%s " "${brew_formulae[@]}" )


  if confirm "Install Rust"; then
    rustup-init
    $HOME/.cargo/bin/rustc --version
  fi
fi

if confirm "Install brew cask apps"; then

  log_header "Installing cask apps..."
  brew tap homebrew/cask-drivers
  brew tap homebrew/cask-versions
  declare -a brew_cask_formulae=("iterm2" "github" "tunnelbear" "discord"
                                "google-chrome" "spotify"  "adobe-creative-cloud" "microsoft-office" "blender"  "caffeine"  "logitech-options" "visual-studio-code-insiders" )
  brew cask install $( printf "%s " "${brew_cask_formulae[@]}" )
fi

if confirm "Install fonts"; then
  log_header "Installing fonts..."
  declare -a brew_fonts=("font-robotomono-nerd-font" "font-roboto" "font-roboto-slab" "font-roboto-mono" )
  brew tap homebrew/cask-fonts
  brew cask install $( printf "%s " "${brew_fonts[@]}" )
fi

if confirm "Install apps from Apple app store"; then
    brew install mas
    if [[ $(mas account) == "Not signed in"* ]]; then
        open -a "App Store"
        prompt "Please login to App Store."
    fi
    # mas lucky magnet
    mas install 441258766
    open -a Magnet
fi

if confirm "Install yarn packages (react)"; then
  log_header "Installing yarn packages..."
  brew install yarn
  declare -a yarn_formulae=("react-native-cli" "react-native" "react-devtools")

  yarn global add $( printf "%s " "${yarn_formulae[@]}" )
fi

if confirm "Reset zsh"; then
  log_header "Installing zsh and its configuration..."
  
  sudo rm -rf "/usr/local/share/zsh" "$HOME/.oh-my-zsh" "$HOME/.p10k.zsh" "${HOME}/.iterm2_shell_integration.zsh"

  log_header "See iTerm2 window to complete zsh and powerlevel10k setup."
  osascript <<EOF
tell application "iTerm"
	tell current session of first window
		write text "sh -c \"\$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\""
		select
		delay 3
		write text "brew install romkatv/powerlevel10k/powerlevel10k"
    select
    delay 3
    write text "curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash"
    select
    write text "zsh"
    select
	end tell
end tell
EOF
  sleep 5
  novus_link "shell/zshrc" ".zshrc"
  novus_link "shell/p10k.zsh" ".p10k.zsh"
fi


if confirm "Reset bash settings"; then
  novus_link "shell/bashrc"        ".bashrc"
  novus_link "shell/bash_profile"  ".bash_profile"
fi


prompt "Please use vscode to Sync via GitHub."
prompt "Manually install iTerm colors and font from apps/iTerm (Settings > Profiles > Colors). Set theme to minimal."

log_success "Completed installation of new macbook. Restart to activate all settings."

if confirm "REMOVE PASSWORD LENGTH RESTRICTION??????????? 1/3"; then
  if confirm "REMOVE PASSWORD LENGTH RESTRICTION??????????? 2/3"; then
    if confirm "REMOVE PASSWORD LENGTH RESTRICTION??????????? 3/3"; then
      pwpolicy -clearaccountpolicies
      passwd
    fi
  fi
fi

if confirm "Restart"; then
  osascript -e 'tell app "loginwindow" to «event aevtrrst»'
fi
