#!/bin/bash
if [ -z "$1" ]; then
	echo "You need to specify a domain. F.x. $0 yii2app.dev"
	exit
fi

domain="$1"
folder="/var/www/$domain"

echo "This action will remove $folder and all its contents."
read -e -p "It cannot be undone. Are you sure? [y/n] " -i "" confirmation

if [ "$confirmation" != "y" ]; then
	echo 'Aborted'
	exit
fi

if grep -q "\"$domain\"" /var/www/Vagrantfile; then
	#removes domain then fix extra ,
	sudo sed -i -e "s/,*\"$domain\",*/,/" \
				-e "s/domains= \[,*\(.*\),*\]/domains= [\1]/" \
				/var/www/Vagrantfile
	echo 'Removed traces from /var/www/Vagrantfile'
fi

if [ -f "/etc/apache2/sites-available/$domain.conf" ]; then
	sudo a2dissite "$domain"
	sudo rm -rf "/etc/apache2/sites-available/$domain.conf"
	sudo service apache2 reload
fi

if [ ! -d "$folder" ]; then
	echo "$domain is not a valid domain. Does $folder exist?"
else
	sudo rm -rf "$folder"
	echo "Directory $folder is now gone"
fi
