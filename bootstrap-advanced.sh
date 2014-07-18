#!/usr/bin/env bash

############## CONFIGURATION OPTIONS ################

# Mysql root password
mysql_root_password=$([ -z "$1" ] && echo 'vagrant' || echo "$1")
# Domain to use
domain=$([ -z "$2" ] && echo "yii2app.dev" || echo "$2")
# Port to use
domain_port=$([ -z "$3" ] && echo "80" || echo "$3")
# Domain to use in admin
admin_domain=$([ -z "$4" ] && echo "admin.$domain" || echo "$4")
# Port to use in admin
admin_domain_port=$([ -z "$5" ] && echo "80" || echo "$5")
# Database name
mysql_database=$([ -z "$6" ] && echo "yii2app" || echo "$6")
# MySQL password
mysql_username=$([ -z "$7" ] && echo "$mysql_database" || echo "$7")
# MySQL password
mysql_password=$([ -z "$8" ] && echo 'n3wp4ss' || echo "$8")

############## END OF CONFIGURATION - STOP EDITING ##############

# Ask everything we need to know to setup the box
# If no stdin avaliable, we use the configuration parameters above
if [ -t 0 ]; then
    read -e -p "MySQL root password: " -i "$mysql_root_password" mysql_root_password
    read -e -p "Domain to use: " -i "$domain" domain
    read -e -p "Port to use: " -i "$domain_port" domain_port
    read -e -p "Domain to use in admin: " -i "admin.$domain" admin_domain
    read -e -p "Port to use in admin: " -i "$admin_domain_port" admin_domain_port
    read -e -p "New MySQL database: " -i "$mysql_database" mysql_database
    read -e -p "New MySQL username: " -i "$mysql_database" mysql_username
    read -e -p "New MySQL password: " -i "$mysql_password" mysql_password
fi;

folder="/var/www/$domain"

# ==================== APPLICATION =========================

############## YII ################

# download project
if [ ! -d "$folder" ]; then
    sudo composer create-project --prefer-dist --stability=dev yiisoft/yii2-app-advanced "$folder"
    # init project
    php $folder/init --env=Development --overwrite=n

    ## Yii cache config. Now uses memcache
    sed -i "s/'class' => 'yii\caching\FileCache',/'class' => 'yii\caching\MemCache',/g" "$folder/common/config/main.php";
else
    cd "$folder"
    sudo composer update --prefer-dist
fi

############## Database ################

## Yii database config
# create user and database
mysql -uroot --password="$mysql_root_password" -e "CREATE SCHEMA IF NOT EXISTS $mysql_database DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -uroot --password="$mysql_root_password" -e "GRANT ALL PRIVILEGES ON $mysql_database.* TO '$mysql_username'@'localhost' IDENTIFIED BY '$mysql_password' WITH GRANT OPTION;";
mysql -uroot --password="$mysql_root_password" -e "GRANT ALL PRIVILEGES ON $mysql_database.* TO '$mysql_username'@'%' IDENTIFIED BY '$mysql_password' WITH GRANT OPTION;";

sudo sed -i -e "s/mysql:host=localhost;dbname=.*',/mysql:host=localhost;dbname=$mysql_database',/" \
        -e "s/'password' => '.*',/'password' => '$mysql_password',/" \
        -e "s/'username' => '.*',/'username' => '$mysql_username',/" "$folder/common/config/main-local.php"

############## APACHE ################

# setup hosts file
VHOST=$(cat <<EOF
# Frontend configuration
<VirtualHost *:$domain_port>
    DocumentRoot $folder/frontend/web
    ServerName $domain
    ServerAlias www.$domain
    <Directory $folder/frontend/web>
        Options All
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

# Backend configuration
<VirtualHost *:$admin_domain_port>
    DocumentRoot $folder/backend/web
    ServerName $admin_domain
    <Directory $folder/backend/web>
        Options All
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

EOF
)
echo "${VHOST}" > "/etc/apache2/sites-available/$domain.conf"

# server ports
if ! grep -q "Listen $domain_port" /etc/apache2/ports.conf; then
    echo "Listen $domain_port" >> /etc/apache2/ports.conf
fi
if ! grep -q "Listen $admin_domain_port" /etc/apache2/ports.conf; then
    echo "Listen $admin_domain_port" >> /etc/apache2/ports.conf
fi

# update Vagrantfile with the new hosts
if ! grep -q "\"$domain\"" /var/www/Vagrantfile; then
    sudo sed -i -e "s/domains= \[\(.+\)\]/domains= [\1,\"$domain\"]/" /var/www/Vagrantfile
fi
if ! grep -q "\"$admin_domain\"" /var/www/Vagrantfile; then
    sudo sed -i -e "s/domains= \[\(.+\)\]/domains= [\1,\"$admin_domain\"]/" /var/www/Vagrantfile
fi

# tell apache to use sites vhost file and configs
sudo a2ensite "$domain"

# restart services using new config
sudo service apache2 reload


############## APPLICATION ################

# install migrations
sudo php $folder/yii migrate up --interactive=0

echo "";
echo "All Done!"
echo "Now add the ip/domain to your hosts file if you didn't already. A little help:"
echo "echo '33.33.33.34 $domain www.$domain $admin_domain' | sudo tee -a /etc/hosts"
echo "Now go to your new sites http://$domain http://$admin_domain and Rock'n roll"
