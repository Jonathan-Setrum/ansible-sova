#!/bin/sh

#SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
#STRING='SovaWordpress'
#printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php

chmod 755 /usr/bin/wget
cd /var/www/html
grep -A 1 -B 47 'since 2.6.0' wp-config-sova.php > wp-config.php
wget -O - https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
grep -A 51 -B 9 'table_prefix' wp-config-sova.php >> wp-config.php
chmod 0 /usr/bin/wget
chown -R 500:sova /var/www/phpMyAdmin
