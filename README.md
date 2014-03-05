
# Custom LAMP vagrant box
  
  
## Stack  
+ apache 2.4 fastcgi  
+ php 5.5 fpm  
+ mysql 5.5  
+ composer  
+ ffmpeg  
+ imagemagick & php extension  
+ curl & php extension  
+ memcached & php extension memcache  

## What it does
+ creates a new mysql database and allow external access   
+ install yii2 advanced template and replace default database values  
+ configure apache hostname for frontend and backend applications   

## How to use
edit bootstrap.sh to change domain and password  
edit your hosts file and add the line:  
>33.33.33.20 mydomain.dev  
to create a new domain run   
>/var/www/bootstap.sh  
and it will prompt to configure   

# Defaults

Domain to use  
> domain="myapp.proj"   
Port to use  
> domain_port="80"  
Domain to use in admin  
> admin_domain="$domain"  
Port to use in admin  
> admin_domain_port="2013"  
MySQL password  
> mysql_username="vagrant"   
MySQL password  
> mysql_password="vagrant"  
Database name   
> mysql_database="myapp"  
