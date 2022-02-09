#!/bin/bash

# Username and password change

RANDOM_PASS=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`
PASS=${1:-$RANDOM_PASS}
if [  -e /root/scripts/sova.passwd ]; then
  mv -f /root/scripts/sova.passwd /root/scripts/old_sova.passwd
else
  cp -f /root/scripts/mysql.passwd /root/scripts/old_sova.passwd
fi
echo $PASS > /root/scripts/sova.passwd

cat /root/scripts/sova.passwd | passwd --stdin sova

# sova username and password mysql
mysql -u root mysql -p`cat /root/scripts/root.passwd` -e "UPDATE user set password=PASSWORD('`cat /root/scripts/sova.passwd`') where User='sova';; FLUSH PRIVILEGES;"
#mysql -u root wordpress -p`cat root.passwd` -e "UPDATE sv_users SET user_pass = MD5('`cat sova.passwd`') WHERE ID = 2"

#htpasswd -mbc /var/www/html/.htpasswd sova "`cat sova.passwd`"
# mysql WP config
sed -i "s/'DB_PASSWORD', '"$(cat /root/scripts/old_sova.passwd)"'/'DB_PASSWORD', '"$(cat /root/scripts/sova.passwd)"'/" /var/www/html/wp-config.php

## mysql WP siteurl
#ifconfig venet0:0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print "http://"$1}' > ipadd.txt
#mysql -u root wordpress -p`cat root.passwd` -e "UPDATE sv_options SET option_value='`cat ipadd.txt`' WHERE option_id =1";
#mysql -u root wordpress -p`cat root.passwd` -e "UPDATE sv_options SET option_value='`cat ipadd.txt`' WHERE option_id =36";
#rm -rf .bash_history mysql.passwd root.passwd sova.sh && history -c

