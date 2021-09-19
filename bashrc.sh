#!/bin/bash

# *************************************
#      BEGIN:: Output tools
# *************************************
bold="\e[1m"
blue="\033[1;34m"
cyan="\033[01;36m"
green="\033[1;32m"
cc="\033[0m"
function statusgood {
	printf "${bold}[${green}STATUS${cyan}::${cc}${bold}BASHRC]${cc} $1\n"
}
function statusnote {
	printf "${bold}[${blue}NOTE${cyan}::${cc}${bold}BASHRC]${cc} $1\n"
}
# *************************************
#        END:: Output tools
# *************************************


statusnote "Setting up bashrc..."

rm ~/.bashrc
mv bashrc.skel ~/.bashrc
chmod u=rw,g=r,o=r ~/.bashrc	# -rw-r--r-- 1 user user   4925 Aug 13 13:07 .bashrc
sudo rm /root/.bashrc
sudo chown root:root rootbashrc.skel
sudo mv rootbashrc.skel /root/.bashrc
sudo chmod u=rw,g=r,o=r /root/.bashrc

statusgood "bashrc set up. Remember to run  . .bashrc  afterwards"
