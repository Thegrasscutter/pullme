#!/bin/bash
declare -a failed=()
declare -i index=0
#update the system
echo "[+] Update and upgrading the system"
apt update && apt upgrade -y
#norwegian lang
echo "[+] Adding norwegian lang to bash and zsh"
echo "setxkbmap no" >> /home/kali/.bashrc
echo "setxkbmap no" >> /home/kali/.zshrc
#update metasploit
echo "[+] Updating metasploit"
apt-get upgrade metasploit-framework
#programs you need
echo "setting up httpie"
curl -SsL https://packages.httpie.io/deb/KEY.gpg | gpg --dearmor -o /usr/share/keyrings/httpie.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" > /etc/apt/sources.list.d/httpie.list
apt update
echo "[+] Installing programs"
apt install -y tmux vim jq crowbar bloodhound
apt install -y httpie docker.io
echo "[+] Enabling docker and adding user to docker"
systemctl enable docker --now
usermod -aG docker $USER

#python libs you need
echo "[+] Installing python packages"
{
        sudo -u kali pip install pwntools
        sudo -u kali pip install pycryptodome
} ||{
        echo "[-] Error something went wrong with python package installation, continuing"
        failed[$index]="python-packages"
        index=$(($index+1))
}

#install sliver
echo "[+] Installing sliver"
{
        curl https://sliver.sh/install| bash
} ||{
        echo "[-] Error something went wrong with sliver installation, continuing"
        failed[$index]="sliver"
        index=$(($index+1))
}

# Github tools
echo "[+] Installing github libs"
gits=(
"https://github.com/ticarpi/jwt_tool.git" 
"https://github.com/carlospolop/PEASS-ng.git"
"https://github.com/PowerShellMafia/PowerSploit.git"
"https://github.com/DominicBreuker/pspy.git"
"https://github.com/internetwache/GitTools.git"
"https://github.com/nidem/kerberoast.git"
"https://github.com/NetDirect/nfsshell.git"
"https://github.com/besimorhino/powercat.git"
"https://github.com/61106960/adPEAS.git"
"https://github.com/decalage2/oletools.git"
"https://github.com/turbo/zero2hero.git"
"https://github.com/kozmer/log4j-shell-poc.git"
"https://github.com/ropnop/kerbrute.git"
"https://github.com/pwndbg/pwndbg.git"
)
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
                sudo -u kali pip install -r requirements.txt
        } || {
                echo "no requirements"
        }
done

cd /usr/share/wordlists
git clone https://github.com/danielmiessler/SecLists
gunzip ./rockyou.txt.gz
#install ngrok
echo "[+] Installing ngrok"
{
        curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list 
        apt update && apt install ngrok
} ||{
        echo "[-] Error something went wrong with ngrok installation, continuing"
        failed[$index]="ngrok"
        index=$(($index+1))
}

echo "[+] Getting linpeas and winpeas"
{
        cd /opt/PEASS-ng/linPEAS/
        wget https://github.com/carlospolop/PEASS-ng/releases/download/20231015-0ad0e48c/linpeas.sh
        cd /opt/PEASS-ng/winPEAS/
        wget https://github.com/carlospolop/PEASS-ng/releases/download/20231015-0ad0e48c/winPEAS.bat
        wget https://github.com/carlospolop/PEASS-ng/releases/download/20231015-0ad0e48c/winPEASx64.exe
        wget https://github.com/carlospolop/PEASS-ng/releases/download/20231015-0ad0e48c/winPEASany_ofs.exe
        wget https://github.com/carlospolop/PEASS-ng/releases/download/20231015-0ad0e48c/winPEASx86_ofs.exe
} || {
        echo "[-] Error something went wrong with linPEAS or winPEAS get, continuing"
        failed[$index]="linPEAS/winPEAS"
        index=$(($index+1))
}

echo "[+] Installing Go"
{
        cd /home/kali/Downloads
        wget https://go.dev/dl/go1.21.1.linux-amd64.tar.gz
        rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz
        export PATH=$PATH:/usr/local/go/bin
}||{
        echo "[-] Error could not install go"
        failed[$index]="go"
        index=$(($index+1))
}
echo "[+] Installing pwndbg"
{
        cd /opt/pwndbg
        ./setup.sh
        echo "source /opt/pwndbg/gdbinit.py" >> /home/kali/.gdbinit
}||{
        echo "[-] Error could not install pwndbg"
        failed[$index]="pwndbg"
        index=$(($index+1))
}
if (( ${#failed[@]} )); then
        echo "Following parts of the script failed"
        echo "${failed[@]}"
fi
echo "[+] Script done!"
