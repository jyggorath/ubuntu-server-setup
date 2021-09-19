#/bin/bash


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
	printf "${bold}[${green}STATUS${cyan}::${cc}${bold}SETUP]${cc} $1\n"
}
function statuswarn {
	printf "${bold}[${yellow}WARNING${cyan}::${cc}${bold}SETUP]${cc} $1\n"
}
function statusnote {
	printf "${bold}[${blue}NOTE${cyan}::::${cc}${bold}SETUP]${cc} $1\n"
}
function statuserror {
	printf "${bold}[${red}ERROR${cyan}::${cc}${bold}SETUP]${cc} $1\n"
}
# *************************************
#        END:: Output tools
# *************************************


if [ $# -lt 1 ]; then
	statuserror "Specify atleast one option:"
	echo "    NanoRC, Python, CommonApps, Apache, ApacheDomain, PHP, PHPSQLite, PHPMySQL"
	echo "    or Full (NanoRC, Python, ApacheDomain, PHPMySQL)"
	echo "    (setup of bashrc and sshd hardening is done regardless)"
	exit 1
fi

full=0
nanorc=0
python=0
commons=0
apache=0
apachedom=0
php=0
phpl=0
phpm=0

for i in $@; do
	if [ "$i" == "Full" ]; then
		nanorc=1
		python=1
		commons=1
		apachedom=1
		phpm=1
		full=1
	fi
done

if [ $full -eq 0 ]; then
	for i in $@; do
		[ "$i" == "NanoRC" ] && nanorc=1
		[ "$i" == "Python" ] && python=1
		[ "$i" == "CommonApps" ] && commons=1
		[ "$i" == "Apache" ] && apache=1
		[ "$i" == "ApacheDomain" ] && apachedom=1
		[ "$i" == "PHP" ] && php=1
		[ "$i" == "PHPSQLite" ] && phpl=1
		[ "$i" == "PHPMySQL" ] && phpm=1
	done
fi

if [ $apache -eq 1 ] && [ $apachedom -eq 1 ]; then
	statuserror "Only 1 Apache option is allowed at a time"
	exit 1
fi

phpsum=$(($php+$phpl+$phpm))
if [ $phpsum -gt 1 ]; then
	statuserror "Only 1 PHP option is allowed at a time"
	exit 1
fi

downloaderror=0
statusnote "Downloading setup scripts..."
wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/sshd_hardening.sh" || downloaderror=1
wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/bashrc.sh" || downloaderror=1
if [ $nanorc -eq 1 ]; then wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/nanorc.sh" || downloaderror=1; fi
if [ $python -eq 1 ]; then wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/python.sh" || downloaderror=1; fi
# download commonapps.sh
if [ $downloaderror -ne 0 ]; then
	statuserror "Error while downloading, make sure there's a network connection and that all the files are present on GitHub."
	exit 1
fi
statusgood "Done downloading setup scripts"

chmod u+x sshd_hardening.sh
chmod u+x bashrc.sh
[ $nanorc -eq 1 ] && chmod u+x nanorc.sh
[ $python -eq 1 ] && chmod u+x python.sh
[ $commons -eq 1 ] && chmod u+x commonapps.sh

./sshd_hardening.sh
./bashrc.sh
[ $nanorc -eq 1 ] && ./nanorc.sh
[ $python -eq 1 ] && ./python.sh
[ $commons -eq 1 ] && ./commonapps.sh

[ $nanorc -eq 1 ] && rm nanorc.sh
[ $python -eq 1 ] && rm python.sh
[ $commons -eq 1 ] && rm commonapps.sh
