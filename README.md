
# Custom LAMP vagrant box
  
## Dependencies
Vagrant plugin [host-manager](https://github.com/smdahlen/vagrant-hostmanager )  
To install type:  
> vagrant plugin install vagrant-hostmanager  

## Stack  
+ apache 2.4 mpm worker with fastcgi  
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

edit [Vagrantfile](https://github.com/gusnips/vagrant-yii2/blob/master/Vagrantfile) to change the [options](#defaults)   

to create a new application run   
>/var/www/bootstap.sh  

and it will prompt to configure   

## Options

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
