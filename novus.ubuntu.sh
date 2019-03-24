cd $HOME/novus.mac/
source lib/util

prompt() {
  read -p "${1}. Press enter to continue."
}

novus_link "shell/bashrc"        ".bashrc"
novus_link "shell/bash_profile"  ".bash_profile"

sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

sudo apt install -y curl apt-transport-https gnupg-curl gnupg-agent git

mkcd $HOME/libs
# Github Desktiop
wget -O ./github_desktop.deb https://github.com/shiftkey/desktop/releases/download/release-1.6.0-linux1/GitHubDesktop-linux-1.6.0-linux1.deb

# chrome 
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c "rm -f /etc/apt/sources.list.d/google-chrome.list"
sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'

sudo apt install -y google-chrome-stable

# vscode
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo sh -c "rm -f /etc/apt/sources.list.d/microsoft.list"
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo sh -c 'rm -f microsoft.gpg'

sudo apt install -y code 

# cisco vpn
wget https://www.nvidia.com/content/includes/Anyconnect/linux64-4.5.02036-predeploy-k9.tar.gz
gunzip linux64-4.5.02036-predeploy-k9.tar.gz
tar -xvf linux64-4.5.02036-predeploy-k9.tar
(cd ./anyconnect-linux64-4.5.02036/vpn/ && sudo ./vpn_install.sh)
rm linux64-4.5.02036-predeploy-k9.tar

# kubernetes  
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo rm /etc/apt/sources.list.d/kubernetes.list
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

# nvidia drivers
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$(. /etc/os-release;echo $ID$VERSION_ID)/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt purge nvidia-*
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo add-apt-repository universe

cd $HOME/libs
wget -O git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

UBUNTU_VER=$(. /etc/os-release;echo $ID$VERSION_ID | sed s/\\.//g)
wget -O cuda.deb https://developer.download.nvidia.com/compute/cuda/repos/$UBUNTU_VER/x86_64/cuda-repo-${UBUNTU_VER}_10.0.130-1_amd64.deb

prompt "Next you will enter the NEW password for root"
sudo passwd root

sudo dpkg -i cuda.deb
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$UBUNTU_VER/x86_64/7fa2af80.pub

 # nvidia-driver-410 in UBUNTU 18
sudo apt install -y \
  ca-certificates \
  cuda-10-0 \
  nvidia-410 \
  software-properties-common \
  kubectl

# CuDNN
prompt "Please download cuDNN v7.3.1 Library for cuda 10 zip from https://developer.nvidia.com/rdp/cudnn-archive and leave it in downloads"
mv $HOME/Downloads/cudnn-10.0-linux-x64-v7.3.1.20.tgz cudnn.tgz
tar -xzvf cudnn.tgz
sudo cp cuda/include/cudnn.h /usr/local/cuda/include
sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn.h /usr/local/cuda/lib64/libcudnn*

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudp apt update

log_header "Installing drivers and apps..."
sudo apt install -y nvidia-docker2

sudo apt install -y python-pip

sudo apt install -y \
  bash-completion \
  aptitude \
  gnome-tweak-tool \
  curl \
  gimp \
  git \
  code \
  nfs-common \
  cifs-utils \
  libopenmpi-dev \
  openssh-client \
  libpangox-1.0-0 \
  ./github_desktop.deb

# rm github_desktop.deb

sudo snap install --classic hub
sudo snap install --classic datagrip
sudo snap install --classic slack
sudo snap install spotify
sudo snap install communitheme

log_header "Installing python dependancies..."
pip  install seaborn pylint autopep8 tf-nightly-gpu jupyter
pip3 install seaborn pylint autopep8 tf-nightly-gpu jupyter

log_header "Installing git configuration..."
novus_link "git/gitattributes"  ".gitattributes"
novus_link "git/gitignore"      ".gitignore"
novus_link "git/gitconfig"      ".gitconfig"

git config --global user.email "amago@nvidia.com"
git config --global user.name "Jai Mago"


ssh-keygen -t rsa -C "amago@Blade" -N "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub
prompt "Please put the previous output here: https://gitlab-master.nvidia.com/profile/keys "
git clone ssh://git@gitlab-master.nvidia.com:12051/ai-infra/ai-infra.git $HOME/ai

log_header "Installing fonts.."
mkdir ~/.fonts
wget -O "/home/amago/.fonts/Roboto Mono Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf?raw=true
wget -O "/home/amago/.fonts/Roboto Mono Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf?raw=true

fc-cache -f -v


log_header "Installing VS Code packages and settings..."
# Install VS Code settings
code --install-extension shan.code-settings-sync

prompt "Please use vscode to Sync extension using github token: aa1c0ee7644de4a515f6941e854c1ad70b4b74d5 and id: f950324ee59d97b001b0f442ba534dd4  .."

sudo apt autoremove

su -c 'echo "
sc-zfs-04:/export/projects.dlar_artifacts   /home/projects.dlar_artifacts  nfs rw,noatime,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=10,sec=sys,vers=3  0 0
sc-zfs-04:/export/scratch.nvdrivenet    /home/scratch.nvdrivenet    nfs rw,noatime,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=10,sec=sys,vers=3  0 0
sc-zfs-04:/export/scratch.dlar_artifacts_nobackup   /home/scratch.dlar_artifacts_nobackup  nfs rw,noatime,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=10,sec=sys,vers=3  0 0
sc-zfs-04:/export/scratch.autopilot2    /home/scratch.autopilot2    nfs rw,noatime,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=10,sec=sys,vers=3  0 0
sc-zfs-05:/export/scratch.autopilot3    /home/scratch.autopilot3    nfs rw,noatime,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=10,sec=sys,vers=3  0 0
sc-zfs-06:/export/scratch.avautolabeling    /home/scratch.avautolabeling    nfs rw,noatime,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=10,sec=sys,vers=3  0 0
sc-zfs-03:/export/scratch.autopilot1    /home/scratch.autopilot1    nfs rw,noatime,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=10,sec=sys,vers=3  0 0" >> /etc/fstab'

echo 'DAZEL_VOLUMES+=[
    "/home/projects.dlar_artifacts:/home/projects.dlar_artifacts",
    "/home/scratch.nvdrivenet:/home/scratch.nvdrivenet",
    "/home/scratch.dlar_artifacts_nobackup:/home/scratch.dlar_artifacts_nobackup",
]' >> /home/amago/.dazelrc

echo '## arrow up
"\e[A":history-search-backward
## arrow down
"\e[B":history-search-forward' >> $HOME/.inputrc

sudo mkdir /home/scratch.autopilot{1,2,3}
sudo mkdir /home/scratch.{avautolabeling,nvdrivenet}
sudo mkdir /home/projects.dlar_artifacts
sudo mkdir /home/scratch.dlar_artifacts_nobackup

sudo usermod -a -G docker $(whoami)

su -c 'echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf'
sudo sysctl -p

###### DRIVEWORKS
sudo apt install xorg-dev libglu1-mesa-dev libusb-1.0-0-dev libglfw3-dev libgles2-mesa-dev python3 python3-pip

curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt install git-lfs
git lfs install

sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install -y gcc-4.9 g++-4.9 gfortran-4.9 ninja-build ccache
sudo apt-get install -y xorg-dev libglu1-mesa-dev libusb-1.0-0-dev libglfw3-dev libgles2-mesa-dev python3 python3-pip
pip3 install --upgrade setuptools --user

cd $HOME
git lfs clone ssh://git@gitlab-master.nvidia.com:12051/driveav/dw/sdk.git
git submodule update --init --recursive
mkcd sdk/build_x86/

prompt "Please relogin and then run ./novus.ubuntu2"
