# Yii2 application vagrant box

## Stack
+ `ubuntu 12.04 32bits (precise32)`
+ `apache 2.4 mpm worker with fastcgi`
+ `php 5.5 fpm`
+ `mysql 5.5`
+ `curl & curl-php extension`
+ `memcached & memcache-php extension`
+ `composer`
+ `yii2 basic or advanced application`

## How to use

clone and init the vagrant box (you need [Vagrant](http://www.vagrantup.com/) installed first)

```shell
$ git clone git@github.com:gusnips/vagrant-yii2.git
$ cd vagrant-yii2
$ vagrant up
```

ssh into the new box and create a new application

```shell
$ vagrant ssh
#Basic or advanced template? /var/www/bootstrap-basic.sh
$ sudo /var/www/bootstrap-advanced.sh
```

Add the domain of your new app to your [hosts file](http://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/)
```
echo '33.33.33.34 yii2app.dev admin.yii2app.dev' | sudo tee -a /etc/hosts
#it will add this line to /etc/hosts
#33.33.33.34 yii2app.dev admin.yii2app.dev
```

use above whatever domain you wanted and the box ip in your [Vagrantfile](https://github.com/gusnips/vagrant-yii2/blob/master/Vagrantfile)

Now access [www.yii2app.dev](www.yii2app.dev) and rock'n roll

## What it does

+ it run composer to create a new app using yii2 advanced or basic template
+ creates a new mysql database and user for the new app
+ change default database values to use the new ones
+ change application cache to memcache
+ add a new apache hostname for frontend and backend applications

## Default Options

Default box options. edit [Vagrantfile](https://github.com/gusnips/vagrant-yii2/blob/master/Vagrantfile) to change it

- `domains= ["yii2app.dev", "www.yii2app.dev","admin.yii2app.dev"]` Vagrant box hostname
- `ip= "33.33.33.34"` Vagrant box IP
- `mysql_root_password="vagrant"` Set mysql root password on installation

Default application options. Edit [bootstap-advanced.sh](https://github.com/gusnips/vagrant-yii2/blob/master/bootstap-advanced.sh) to change it

- `mysql_root_password="vagrant"` MySQL root password. The one you choose during installation.
- `domain="yii2app.dev"` Domain to use.
- `domain_port="80"` Port to use.
- `admin_domain="admin.yii2app.dev"` Domain to use in admin. Advanced app only.
- `admin_domain_port="80"` Port to use in admin. Advanced app only.
- `mysql_database="yii2app"` New database name.
- `mysql_username="yii2app"` MySQL username.
- `mysql_password="n3wp4ss"` MySQL password.

optionally you can run the command passing the parameters
```shell
sudo /var/www/bootstap-basic.sh myp4ss mydomain.dev 80 appdb dbuser newp4ss
```
or for advanced template (in this order)
```shell
sudo /var/www/bootstap-advanced.sh myp4ss mydomain.dev 80 admin.mydomain.dev 80 appdb dbuser newp4ss
```


### Remove a site

```shell
sudo /var/www/remove-site.sh sitedomain.dev
```
