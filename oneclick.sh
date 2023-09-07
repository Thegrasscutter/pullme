#!/bin/bash
#update the system
echo "update and upgrading the system"
apt update && apt upgrade -y
#norwegian lang
echo "adding norwegian lang to bash and zsh"
echo "setxkbmap no" >> ~/.bashrc
echo "setxkbmap no" >> ~/.zshrc
#update metasploit
echo "updating metasploit"
apt-get upgrade metasploit-framework
#programs you need
echo "setting up httpie"
curl -SsL https://packages.httpie.io/deb/KEY.gpg | gpg --dearmor -o /usr/share/keyrings/httpie.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" > /etc/apt/sources.list.d/httpie.list
apt update
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
echo "installing github libs"
gits=("https://github.com/ticarpi/jwt_tool.git" "https://github.com/carlospolop/PEASS-ng.git" "https://github.com/PowerShellMafia/PowerSploit.git" "https://github.com/DominicBreuker/pspy.git" "https://github.com/internetwache/GitTools.git" "https://github.com/nidem/kerberoast.git" "https://github.com/NetDirect/nfsshell.git" "https://github.com/besimorhino/powercat.git" "https://github.com/61106960/adPEAS.git" "https://github.com/danielmiessler/SecLists.git" "https://github.com/decalage2/oletools.git" "https://github.com/turbo/zero2hero.git" "https://github.com/kozmer/log4j-shell-poc.git" "https://github.com/ropnop/kerbrute.git")
for i in "${gits[@]}"
do
        cd /opt
        git clone "$i"
done
for i in $(ls /opt/)
do
        cd /opt
        cd $i
        {
                pip install -r requirements.txt
        } || {
                echo "no requirements"
        }
done

#install ngrok
echo "installing ngrok"
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && apt install ngrok
