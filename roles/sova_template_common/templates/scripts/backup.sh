#!/bin/bash

PATH=/usr/sbin:/sbin:/bin:/usr/bin

user="root"
pass="`cat /root/scripts/root.passwd`"
host=$(hostname -f)

dest="/backup"

#now="$(date +"%Y-%m-%d_%H-%M-%S")"
now=`date +%Y-%m-%d`
last=$(date +%Y-%m-%d --date='1 week ago')

backup_files="/var/www/html"
upload_files="/var/www/html/wp-content/uploads/"
archive_www_file="$host-web-$now.tgz"
archive_upload_file="$host-upload-$now.tgz"
db_file="$host-db-$now.gz"

mysqldump -u $user -h localhost -p$pass wordpress | gzip -9 > $dest/$db_file

tar czPf $dest/$archive_www_file $backup_files --exclude='/var/www/html/wp-content/uploads'
tar czPf $dest/$archive_upload_file $upload_files

# upload backup to s3
/usr/bin/s3-cli put $dest/$db_file s3://sova.sovabackup/database/
/usr/bin/s3-cli put $dest/$archive_www_file s3://sova.sovabackup/web/
/usr/bin/s3-cli put $dest/$archive_upload_file s3://sova.sovabackup/web/

# delete old backups from s3
/usr/bin/s3-cli del --recursive s3://sova.sovabackup/database/$host-db-$last.gz
/usr/bin/s3-cli del --recursive s3://sova.sovabackup/web/$host-web-$last.tgz
/usr/bin/s3-cli del --recursive s3://sova.sovabackup/web/$host-upload-$last.tgz

rm -rf $dest/*
#find $dest/ -maxdepth 1 -type d -mtime +6 -exec echo "Removing Directory {}" \; -exec rm -rf "{}" \;
