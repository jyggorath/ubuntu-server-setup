#!/bin/bash


# *************************************
#      BEGIN:: Output tools
# *************************************
bold="\e[1m"
underlined="\e[4m"
red="\033[1;31m"
yellow="\033[0;33m"
blue="\033[1;34m"
cyan="\033[01;36m"
green="\033[1;32m"
cc="\033[0m"
function statusgood {
	printf "${bold}[${green}STATUS${cyan}::${cc}${bold}COMMONAPPS]${cc} $1\n"
}
function statusnote {
	printf "${bold}[${blue}NOTE${cyan}::::${cc}${bold}COMMONAPPS]${cc} $1\n"
}
function statuserror {
	printf "${bold}[${red}ERROR${cyan}::${cc}${bold}COMMONAPPS]${cc} $1\n"
}
# *************************************
#        END:: Output tools
# *************************************



# Command 'srm' not found, but can be installed with:	sudo apt install secure-delete
statusnote "Installing srm..."
sudo apt -y install secure-delete &> /dev/null
if [ $? -gt 0 ]; then
	statuserror "Error installing srm"
	exit 1
fi
statusgood "Installed srm"

# Command 'rar' not found, but can be installed with:	sudo apt install rar
statusnote "Installing rar..."
sudo apt -y install rar &> /dev/null
if [ $? -gt 0 ]; then
	statuserror "Error installing rar"
	exit 1
fi
statusgood "Installed rar"

# Command 'unrar' not found, but can be installed with:	sudo apt install unrar
statusnote "Installing unrar..."
sudo apt -y install unrar &> /dev/null
if [ $? -gt 0 ]; then
	statuserror "Error installing unrar"
	exit 1
fi
statusgood "Installed unrar"

# Command 'unzip' not found, but can be installed with:	sudo apt install unzip
statusnote "Installing unzip..."
sudo apt -y install unzip &> /dev/null
if [ $? -gt 0 ]; then
	statuserror "Error installing unzip"
	exit 1
fi
statusgood "Installed unzip"
