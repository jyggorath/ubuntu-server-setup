#!/bin/bash

# https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04

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
	printf "${bold}[${green}STATUS${cyan}::${cc}${bold}BASIC]${cc} $1\n"
}
function statusnote {
	printf "${bold}[${blue}NOTE${cyan}::::${cc}${bold}BASIC]${cc} $1\n"
}
function statuserror {
	printf "${bold}[${red}ERROR${cyan}::${cc}${bold}BASIC]${cc} $1\n"
}
# *************************************
#        END:: Output tools
# *************************************




# *************************************
#      BEGIN:: Input validation
# *************************************
if [ $# -lt 1 ]; then
	statuserror "username required as input"
	exit 1
fi
username="$1"
password=""
if [[ ! "$username" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]; then
	statuserror "Invalid username"
	exit 1
fi
if [ $# -ge 2 ]; then
	password="$2"
fi
if [ "$password" == "" ]; then
	ok=0
	while [ $ok -ne 1 ]; do
		echo -n "Password:"
		read -s p1
		echo ""
		echo -n "Repeat password:"
		read -s p2
		echo ""
		[ "$p1" == "$p2" ] && ok=1 || echo "Doesn't match, try again"
	done
	password="$p1"
	p1=""
	p2=""
fi
# *************************************
#        END:: Input validation
# *************************************




# *************************************
#      BEGIN:: Update & upgrade
# *************************************
statusnote "Running upgrade..."
error=0
apt -qq update && apt -y update &> /dev/null || error=1
if [ $? -gt 0 ] || [ $error -eq 1 ]; then
	statuserror "Some error occured running update/upgrade"
	exit 1
fi
statusgood "Update complete"
# *************************************
#        END:: Update & upgrade
# *************************************




# *************************************
#      BEGIN:: User setup
# *************************************
statusnote "Creating user '$username'..."
adduser --quiet -gecos "" --disabled-password "$username" > .tempo 2> .tempe
chpasswd <<<"$username:$password" >> .tempo 2>> .tempe
usermod -aG sudo "$username" >> .tempo 2>> .tempe
rsync --archive --chown="$username":"$username" ~/.ssh /home/"$username" >> .tempo 2>> .tempe
if [ $(cat .tempe | wc -l) -ne 0 ]; then
	statuserror "Error in usersetup. Possible source commands: adduser, chpasswd, usermod, rsync. Review dumps: stdout: .tempo  stderr: .tempe"
	exit 1
fi
statusgood "Created user '$username'"
# *************************************
#        END:: User setup
# *************************************




# *************************************
#      BEGIN:: Activate firewall
# *************************************
statusnote "Setting up UFW..."
ufw allow OpenSSH > .tempo 2> .tempe
ufw enable >> .tempo 2>> .tempe
if [ $(cat .tempe | wc -l) -ne 0 ]; then
	statuserror "Error in ufw. Review dumps: stdout: .tempo  stderr: .tempe"
	exit 1
fi
statusgood "UFW set up"
# *************************************
#        END:: Activate firewall
# *************************************




# *************************************
#      BEGIN:: Ending
# *************************************
rm .tempo
rm .tempe
statusgood "Finished"
echo "*********************************"
echo "  Now: Log out, and log back in "
echo "       using the user:"
echo "        '$username'"
echo "       SSH keyes have been "
echo "       set up. Afterwards, "
echo "       continue with setup.sh"
echo "*********************************"
# *************************************
#        END:: Ending
# *************************************
