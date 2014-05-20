
# Yii2 advanced application vagrant box
  
## Dependencies
[Vagrant](http://www.vagrantup.com/)  
Vagrant plugin [host-manager](https://github.com/smdahlen/vagrant-hostmanager )  
To install type:  
> vagrant plugin install vagrant-hostmanager  

## Stack  
+ apache 2.4 mpm worker with fastcgi  
+ php 5.5 fpm  
+ mysql 5.5  
+ composer  
+ curl & php extension  
+ memcached & php extension memcache  

## What it does
+ creates a new mysql database and allow external access   
+ install yii2 advanced template. Replace default database values with configuration ones and change to use memcache as cache  
+ configure apache hostname for frontend and backend applications   

## How to use

edit [Vagrantfile](https://github.com/gusnips/vagrant-yii2/blob/master/Vagrantfile) to change the [options](#options)   

to create a new application run   
>/var/www/bootstap.sh  

and it will prompt to configure   

## Options

Domain to use  
>domain="openwings.dev"   

Port to use  
>domain_port="80"  

Domain to use in admin  
>admin_domain="openwings.dev"  

Port to use in admin  
>admin_domain_port="2013"  

MySQL root password  
> mysql_root_password="p4s$w0rd"  

MySQL password
>mysql_username="openwings"   

MySQL password
>mysql_password="p4s$w0rd"  

Database name  
>mysql_database="openwings"  
