#!/bin/bash
#update the system
echo "update and upgrading the system"
apt update && apt upgrade
#norwegian lang
echo "adding norwegian lang to bash and zsh"
echo "setxkbmap no" >> ~/.bashrc
echo "setxkbmap no" >> ~/.zshrc
#update metasploit
echo "updating metasploit"
msfupdate
#programs you need
echo "installing programs"
apt install -y tmux vim jq httpie docker.io crowbar
echo "enabling docker and adding user to docker"
systemctl enable docker --now
usermod -aG docker $USER

#python libs you need
echo "installing python packages"
sudo -u kali pip install pwntools
sudo -u kali pip install pycrypto
#install sliver
echo "installing sliver"
curl https://sliver.sh/install| bash
# Github tools
gclonecd() {
        git clone "$1" && cd "$(basename "$1" .git)"
        {
                sudo -u kali pip install -r ./requirements
        } || {
                exit $1
        }
}
echo "installing github libs"
declare -a gits("https://sudo github.com/ticarpi/jwt_tool.sudo git" "https://sudo github.com/carlospolop/PEASS-ng.sudo git" "https://sudo github.com/PowerShellMafia/PowerSploit.sudo git" "https://sudo github.com/DominicBreuker/pspy.sudo git" "https://sudo github.com/internetwache/GitTools.sudo git" "https://sudo github.com/nidem/kerberoast.sudo git" "https://sudo github.com/NetDirect/nfsshell.sudo git" "https://sudo github.com/besimorhino/powercat.sudo git" "https://sudo github.com/61106960/adPEAS.sudo git" "https://sudo github.com/danielmiessler/SecLists.sudo git" "https://sudo github.com/decalage2/oletools.sudo git" "https://sudo github.com/turbo/zero2hero.sudo git" "https://sudo github.com/kozmer/log4j-shell-poc.sudo git" "https://sudo github.com/ropnop/kerbrute.sudo git")
for i in "${gits[@]}"
do
        cd /opt
        gclonecd($i)
done

#install ngrok
echo "installing ngrok"
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && apt install ngrok
