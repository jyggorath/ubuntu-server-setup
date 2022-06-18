#!/bin/bash


# https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-20-04
# https://www.digitalocean.com/community/tutorials/how-to-set-up-apache-virtual-hosts-on-ubuntu-18-04
# https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-ubuntu-20-04
# https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-20-04

# 403 after vhost setup
# Fix by adding Directory-thingy in the vhost conf:
# <Directory /home/mats/data/>	# Qoutes seem optional?
# 	AllowOverride All			# Allows .htaccess to override this (needed for .htaccess to work)
# 	Options FollowSymLinks		# Unsure if necessary, but on-by-default also in Directory-conf for /, so should be alright
# 	Require all granted			# Grants formal access to the dir, and fixes the 403-status
# </Directory>
# 
# 
# in /etc/apache2/conf-available/security.conf
# ServerTokens Prod	# Only webserver name, no version
# ServerSignature Off	# No visible serverdetails in "footer" at all
# 
# 
# AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using ::1. Set the 'ServerName' directive globally to suppress this message
# sudo nano /etc/apache2/apache2.conf
# # append line:
# ServerName 127.0.0.1
# # (ServerName is set in the vhost conf, but apache would like it to be set globally as well, as fallback (which is why it's pointing to default localhost))
# 
# 
# PHP routing with htaccess should work out of the box if apache conf is correctly set up
# 
# PDO works out of the box, but each db method must have a driver. ex sqlite:
# $ sudo apt install php-sqlite3
# 
# cURL in PHP DOESN'T work out of the box, requires:
# $ sudo apt install php-curl
# 
# JSON in PHP works out of the box
# 
# DateTimeImmutable in PHP works out of the box
# 
# In order for file operations to work in PHP, the dir in quesion must be owned by the www-data user
# $ sudo chown -R www-data:www-data dir/
# 
# mb_* function DOESN'T work out of the box, requires:
# $ sudo apt install php-mbstring

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
	printf "${bold}[${green}STATUS${cyan}::${cc}${bold}APACHE]${cc} $1\n"
}
function statuswarn {
	printf "${bold}[${yellow}WARNING${cyan}::${cc}${bold}APACHE]${cc} $1\n"
}
function statusnote {
	printf "${bold}[${blue}NOTE${cyan}::::${cc}${bold}APACHE]${cc} $1\n"
}
function statuserror {
	printf "${bold}[${red}ERROR${cyan}::${cc}${bold}APACHE]${cc} $1\n"
}
# *************************************
#        END:: Output tools
# *************************************


domain=""
email=""

if [ "$1" == "domain" ]; then
	if [ $# -lt 2 ] || [ "$2" == "" ]; then
		statuswarn "No domain supplied, please input over stdin:"
		echo -n "Domain: "
		read domain
	else
		domain="$2"
	fi
	if [ $# -lt 3 ] || [ "$3" == "" ]; then
		statuswarn "No email for urgent renewal and security notices supplied, please input over stdin:"
		echo -n "Email: "
		read email
	else
		email="$3"
	fi
fi


statusnote "Installing apache2..."
sudo apt -y install apache2 &> /dev/null
if [ $? -gt 0 ]; then
	statuserror "Error installing apache2"
	exit 1
fi
statusgood "Installed apache2"

sudo ufw allow "Apache Full"
statusgood "Firewall configured for apache"

[ "$1" == "simple" ] && exit


statusnote "Setting up directory structure..."
sudo mkdir -p "/var/www/$domain/public_html"
downloaderror=0
wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/skel_files/demopage.html.skel" || downloaderror=1
if [ $downloaderror -ne 0 ]; then
	statuserror "Error downloading demo page skel file. Check GitHub and internet connection."
	exit 1
fi
sudo mv demopage.html.skel "/var/www/$domain/public_html/"
sudo chown -R www-data:www-data "/var/www/$domain/"
statusgood "Directory structure set up"

statusnote "Setting up virtual host..."
downloaderror=0
wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/skel_files/siteconf.skel" || downloaderror=1
if [ $downloaderror -ne 0 ]; then
	statuserror "Error downloading vhost conf skel file. Check GitHub and internet connection."
	exit 1
fi
sed -i "s/DOMAINGOESHERE/$domain/" siteconf.skel
mv siteconf.skel "$domain.conf"
sudo mv "$domain.conf" /etc/apache2/sites-available/
sudo chown root:root "/etc/apache2/sites-available/$domain.conf"
sudo chmod u=rw,g=r,o=r "/etc/apache2/sites-available/$domain.conf"	# -rw-r--r-- 1 root root 1332 Jul  5 07:11 000-default.conf
statusgood "Virtual host set up"

statusnote "Applying config..."
sudo a2ensite "$domain.conf"
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
sudo apache2ctl configtest &> .tmp
testresult=$(cat .tmp | egrep -e "^Syntax OK$")
if [ "$testresult" == "" ]; then
	statuserror "Apache configtest failed. Run   sudo apache2ctl configtest   to see what's wrong."
	rm .tmp
	exit 1
fi
[ $(cat .tmp | wc -l) -gt 1 ] && statuswarn "Apache config test produced warning(s). Run   sudo apache2ctl configtest   to see what's \"wrong\"."
rm .tmp
sudo systemctl restart apache2
statusgood "Config applied"

statusnote "Installing certbot..."
sudo apt -y install certbot &> /dev/null
if [ $? -gt 0 ]; then
	statuserror "Error installing certbot"
	exit 1
fi
sudo apt -y install python3-certbot-apache &> /dev/null
if [ $? -gt 0 ]; then
	statuserror "Error installing python3-certbot-apache"
	exit 1
fi
statusgood "Installed certbot"

statusnote "Setting up certbot..."
certboterror=0
sudo certbot --apache --non-interactive --agree-tos --no-eff-email -m "$email" -d "$domain",www."$domain" --redirect || certboterror=1
if [ $certboterror -ne 0 ]; then
	statuserror "Error setting up certbot. Try running   sudo certbot --apache   manually instead."
	exit 1
fi
result=$(sudo systemctl status certbot.timer | grep "Active: active")
if [ "$result" == "" ]; then
	statuserror "Error: certbot timer isn't running. Run   sudo systemctl status certbot.timer   to check status."
	exit 1
fi
sudo certbot renew --dry-run &> .tmp
result=$(cat .tmp | grep "Congratulations, all renewals succeeded.")
rm .tmp
if [ "$result" == "" ]; then
	statuserror "Renewal dry run failed. Run   sudo certbot renew --dry-run   to see error."
	exit 1
fi
statusgood "certbot set up"
