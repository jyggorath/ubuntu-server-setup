#!/bin/bash

# *************************************
#      BEGIN:: Output tools
# *************************************
bold="\e[1m"
red="\033[1;31m"
blue="\033[1;34m"
cyan="\033[01;36m"
green="\033[1;32m"
cc="\033[0m"
function statusgood {
	printf "${bold}[${green}STATUS${cyan}::${cc}${bold}SSHD]${cc} $1\n"
}
function statusnote {
	printf "${bold}[${blue}NOTE${cyan}::${cc}${bold}SSHD]${cc} $1\n"
}
function statuserror {
	printf "${bold}[${red}ERROR${cyan}::${cc}${bold}SSHD]${cc} $1\n"
}
# *************************************
#        END:: Output tools
# *************************************


statusnote "Setting up main nanorc..."

downloaderror=0
wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/skel_files/nanorc.skel" || downloaderror=1
if [ $downloaderror -ne 0 ]; then
	statuserror "Error downloading nanorc skel file. Check GitHub and internet connection."
	exit 1
fi

[ -f "/etc/nanorc" ] && sudo rm /etc/nanorc
sudo chown root:root nanorc.skel
sudo mv nanorc.skel /etc/nanorc
sudo chmod u=rw,g=r,o=r /etc/nanorc	# -rw-r--r-- 1 root root       8330 Jul 28 11:37 nanorc

statusgood "Main nanorc set up"



# /usr/share/nano/
# ...
# -rw-r--r-- 1 root root 1461 Jul 28 11:47 perl.nanorc
# -rw-r--r-- 1 root root  713 Jul 28 11:47 php.nanorc
# -rw-r--r-- 1 root root  839 Jul 28 11:47 po.nanorc
# -rw-r--r-- 1 root root 3093 Jul 28 11:47 postgresql.nanorc
# -rw-r--r-- 1 root root  670 Jul 28 11:47 pov.nanorc
# -rw-r--r-- 1 root root  784 Jul 28 11:47 python.nanorc
# ...

statusnote "Setting up language specific nano rc's..."

downloaderror=0
wget -q "https://github.com/jyggorath/ubuntu-server-setup/blob/main/skel_files/nanorcs.tar.gz?raw=true" || downloaderror=1
if [ $downloaderror -ne 0 ]; then
	statuserror "Error downloading language rc archive. Check GitHub and internet connection."
	exit 1
fi

sudo rm /usr/share/nano/*
mkdir .setuptmp
cd .setuptmp/
mv ../nanorcs.tar.gz .
tar xf nanorcs.tar.gz
rm nanorcs.tar.gz
sudo chown root:root *
sudo mv * /usr/share/nano/
cd ..
rm -r .setuptmp/

statusgood "Language specific nano rc's set up"
