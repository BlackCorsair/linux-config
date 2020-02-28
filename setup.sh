#!/bin/bash

### CHECKS THE PACKAGE MANAGER ###

if [ -f /etc/os-release ]; then
	echo "checking the os-release..."
	if [[ -n $(grep -nr debian /etc/os-release) ]]; then
		PKG_MGR='apt'
	fi
fi

echo "SETUP: INFO: package manager in use is $PKG_MGR"


### INSTALL BASIC PROGRAMS ###
install_basic_programs(){
	sudo $PKG_MGR update
	sudo $PKG_MGR upgrade -y
	sudo $PKG_MGR autoremove -y
	sudo $PKG_MGR install vim tmux htop git curl wget python3 virtualenv \
                    python3-pip gcc g++ make cmake zsh snapd -y
}

### SETUP VIM ###
vim_setup(){
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	cp config_files/vimrc ~/.vimrc
	vim +PluginInstall +qall
}

### SETUP TMUX ###
tmux_setup(){
    echo "setting up tmux..."
	cd ~/ || exit
	git clone https://github.com/gpakosz/.tmux.git
	ln -s -f .tmux/.tmux.conf .
	cp .tmux/.tmux.conf.local .
	exit
}

### SETUP BASHRC ###
bash_setup(){
        {
                echo
                "set -o vi"
                "alias ll='ls -l'"
                "alias ia='ip -c a'"
                "alias vi='vim'"
                "alias kgp='kubectl get pods '"
                "alias kdelp='kubectl delete pods '"
                "alias kdp='kubectl describe pod '"
        } >> ~/.bashrc
}

### SETUP ZSH ###
zsh_setup(){
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	{
                echo
                "set -o vi"
                "alias ll='ls -l'"
                "alias ia='ip -c a'"
                "alias vi='vim'"
                "alias kgp='kubectl get pods '"
                "alias kdelp='kubectl delete pods '"
                "alias kdp='kubectl describe pod '"
        } >> ~/.zshrc
}

### INSTALL SPOTIFY ###
install_spotify(){
    sudo systemctl start snapd
    sudo snap install spotify
}

### INSTALL VSCODE ###
install_vscode(){
    echo "Installing vscode"
    wget -O ~/Downloads/vscode.deb https://go.microsoft.com/fwlink/?LinkID=760868
    sudo apt install ~/Downloads/vscode.deb -y
    rm -rf ~/Downloads/vscode.deb
    cp config_files/vscode-settings.json ~/.config/Code/User/settings.json
}

### INSTALL KUBECTL ###
install_kubectl(){
    echo "Installing kubectl"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/"$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
}

### INSTALL MINIKUBE ###
install_minikube(){
    echo "Installing minikube"
    sudo apt install -y virtualbox
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
        && chmod +x minikube
    sudo install minikube /usr/local/bin/
    sudo rm -rf minikube
}

### DOCKER INSTALLATION ###
install_docker(){
	# from https://docs.docker.com/install/linux/docker-ce/ubuntu/
	if [ "apt" == $PKG_MGR ]; then
		sudo apt-get remove -y docker docker-engine docker.io containerd runc
		sudo apt-get update
		sudo apt-get install -y \
                        apt-transport-https \
                        ca-certificates \
                        curl \
                        gnupg-agent \
                        software-properties-common
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
		sudo add-apt-repository \
			"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   			$(lsb_release -cs) \
   			stable"
		sudo apt-get update
		sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	fi
	sudo usermod -aG docker $USER
}

### MAIN ###
install_basic_programs
vim_setup
bash_setup
zsh_setup
tmux_setup
install_vscode
install_spotify
install_docker
install_kubectl
install_minikube
