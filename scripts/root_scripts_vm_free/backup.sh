#!/bin/bash
 
PATH=/usr/sbin:/sbin:/bin:/usr/bin
 
user="root"
pass="`cat /root/scripts/root.passwd`"
host=$(hostname -f)
 
dest="/backup"
 
now="$(date +"%Y-%m-%d_%H-%M-%S")"
now=`date +%Y-%m-%d`
last=$(date +%Y-%m-%d --date='1 week ago')

backup_files="/var/www/html"
archive_file="$host-web-$now.tgz"
db_file="$host-db-$now.gz"

mysqldump -u $user -h localhost -p$pass wordpress | gzip -9 > $dest/$db_file

tar czPf $dest/$archive_file $backup_files

# upload backup to s3
/usr/bin/s3cmd put $dest/$db_file s3://sovabackup/database/
/usr/bin/s3cmd put $dest/$archive_file s3://sovabackup/web/

# delete old backups from s3
/usr/bin/s3cmd del --recursive s3://sovabackup/database/$host-db-$last.gz
/usr/bin/s3cmd del --recursive s3://sovabackup/web/$host-web-$last.tgz

rm -rf $dest/*
#find $dest/ -maxdepth 1 -type d -mtime +6 -exec echo "Removing Directory {}" \; -exec rm -rf "{}" \;
