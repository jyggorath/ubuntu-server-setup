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
	printf "${bold}[${green}STATUS${cyan}::${cc}${bold}PYTHON]${cc} $1\n"
}
function statusnote {
	printf "${bold}[${blue}NOTE${cyan}::${cc}${bold}PYTHON]${cc} $1\n"
}
function statuserror {
	printf "${bold}[${red}ERROR${cyan}::${cc}${bold}PYTHON]${cc} $1\n"
}
# *************************************
#        END:: Output tools
# *************************************


statusnote "Setting up python..."

sudo apt -y install python3-pip &> /dev/null

if [ $? -gt 0 ]; then
	statuserror "There were errors installing pip with apt install"
	exit 1
fi

# atexit is standard?
python3 -m pip install -q readline
python3 -m pip install -q numpy
python3 -m pip install -q beautifulsoup4

downloaderror=0
wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/skel_files/pythonrc.skel" || downloaderror=1
if [ $downloaderror -ne 0 ]; then
	statuserror "Error downloading pythonrc skel file. Check GitHub and internet connection."
	exit 1
fi

username=$(whoami)
sed -i "s/USERNAMEGOESHERE/$username/" pythonrc.skel
[ -f "~/.pythonrc" ] && rm ~/.pythonrc
mv pythonrc.skel ~/.pythonrc
chmod u=rw,g=ro=r ~/.pythonrc	# -rw-r--r-- 1 user user   2691 Jul 28 11:29 .pythonrc

statusgood "Python set up"
