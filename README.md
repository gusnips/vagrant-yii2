
# Custom LAMP vagrant box

- apache 2.4 fastcgi 
- php 5.5 fpm
- mysql 5.5
- composer
- ffmpeg
- imagemagick & php extension
- curl & php extension
- memcached & php extension memcache


- creates a new mysql database and allow external access 
- install yii2 advanced template and replace default database values
- configure apache hostname for frontend and backend applications 


edit bootstrap.sh to change domain and password


edit your hosts file and add the line:

33.33.33.20 mydomain.dev

to create a new domain run 

/var/www/bootstap.sh

and it will prompt to configure 
