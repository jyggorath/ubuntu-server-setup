#!/bin/bash

# https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-18-04


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


statusnote "Hardening SSHD config..."

downloaderror=0
wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/skel_files/sshdconf.skel" || downloaderror=1
if [ $downloaderror -ne 0 ]; then
	statuserror "Error downloading sshd_config skel file. Check GitHub and internet connection."
	exit 1
fi

sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo mv sshdconf.skel /etc/ssh/sshd_config
sudo chown root:root /etc/ssh/sshd_config
sudo chmod u=rw,g=r,o=r /etc/ssh/sshd_config	# -rw-r--r-- 1 root root   3244 Sep 19 14:13 sshd_config

if [ $(sudo sshd -t | wc -l) -ne 0 ]; then
	statuserror "Something not right in the config, please adress:"
	sudo sshd -t
	exit 1
fi

sudo service sshd reload && statusgood "SSHD config hardened"
