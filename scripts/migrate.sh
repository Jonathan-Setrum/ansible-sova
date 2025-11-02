echo Usage: migrate.sh [Source IP] [Destination IP]
if [ "$#" -ne 2 ];
then
	echo 'Missing One or more IP Addresses'
	exit
fi

SIP=$1
DIP=$2

# copy source user & pass
ssh -t $SIP "cut -d: -f1 < /etc/passwd | grep s0 > src_user"
scp -P 10022 $SIP:~/src_user .
ssh -t $SIP "rm src_user"
ssh -t $SIP "cat ~/scripts/sova.passwd > src_pass"
scp -P 10022 $SIP:~/src_pass .
ssh -t $SIP "rm src_pass"

# copy dest user & pass
ssh -t $DIP "cut -d: -f1 < /etc/passwd | grep s0 > dst_user"
scp -P 10022 $DIP:~/dst_user .
ssh -t $DIP "rm dst_user"
ssh -t $DIP "cat ~/scripts/sova.passwd > dst_pass"
scp -P 10022 $DIP:~/dst_pass .
ssh -t $DIP "rm dst_pass"

SrcUser=`cat src_user`
SrcPass=`cat src_pass`
DstUser=`cat dst_user`
DstPass=`cat dst_pass`

rm -f src_user
rm -f src_pass
rm -f dst_user
rm -f dst_pass

# backup at source
echo 'Backup At Source (y/n default=n)?'
read ANS
if [ "$ANS" == "y" ]
then
	ssh -t $SIP "mysqldump -u$SrcUser -p$SrcPass wordpress > /var/www/html/dumpfilename.sql"
	ssh -t $SIP "tar -zcvf backup.tar.gz /var/www/html"
fi

# upload to hproxy
echo 'Upload To hproxy (y/n default=n)?'
read ANS
if [ "$ANS" == "y" ]
then
	scp -P 10022 $SIP:~/backup.tar.gz .
fi

# delete at source
echo 'Delete At Source (y/n default=n)?'
read ANS
if [ "$ANS" == "y" ]
then
	ssh -t $SIP "rm -f /var/www/html/dumpfilename.sql"
	ssh -t $SIP "rm -f backup.tar.gz"
fi

# upload to destination
echo 'Upload to Destination (y/n default=n)?'
read ANS
if [ "$ANS" == "y" ]
then
	scp -P 10022 backup.tar.gz $DIP:~/
fi

# delete at hproxy
echo 'Delete At hproxy (y/n default=n)?'
read ANS
if [ "$ANS" == "y" ]
then
	rm -f backup.tar.gz
fi

# restore
echo 'Restore At Destination (y/n default=n)?'
read ANS
if [ "$ANS" == "y" ]
then
	ssh -t $DIP "rm -rf /var/www/html"
	ssh -t $DIP "tar -zxvf backup.tar.gz -C /"
	ssh -t $DIP "chown -R 500:sova /var/www/html"
	ssh -t $DIP "mysql -u$DstUser -p$DstPass wordpress < /var/www/html/dumpfilename.sql"
fi

# delete
echo 'Delete At Destination - do not delete if restore fails (y/n default=n)?'
read ANS
if [ "$ANS" == "y" ]
then
	ssh -t $DIP "rm -f /var/www/html/dumpfilename.sql"
	ssh -t $DIP "rm -rf backup.tar.gz"
fi

# update WP-CONFIG.PHP
echo 'Update Configs (y/n default=n)?'
read ANS
if [ "$ANS" == "y" ]
then
	ssh -t $DIP "sed -i -e 's|$SrcUser|$DstUser|g' /var/www/html/wp-config.php"
	ssh -t $DIP "sed -i -e 's|$SrcPass|$DstPass|g' /var/www/html/wp-config.php"
fi

# UPDATE sv_options SET option_value='$HOSTNAME' WHERE option_name='site_url' OR option_name='home'

# copy SSL - NOT APPLICABLE FOR FREE TO PAID PLAN MIGRATION
#echo 'COPY SSL (y/n default=n)?'
#read ANS
#if [ "$ANS" == "y" ];
#	scp -P 10022 $SIP:/etc/httpd/conf.d/ssl.conf ssl.conf
#	scp -P 10022 ssl.conf $DIP:/etc/httpd/conf.d/ssl.conf
#	rm -f ssl.conf
#	scp -P 10022 $SIP:/etc/pki/tls/certs/public.crt
#	scp -P 10022 public.crt $DIP:/etc/pki/tls/certs/public.crt
#	rm -f public.crt
#	scp -P 10022 $SIP:/etc/pki/tls/private/private.key
#	scp -P 10022 ssl.conf $DIP:/etc/pki/tls/private/private.key
#	rm -f private.key
#	scp -P 10022 $SIP:/etc/pki/tls/certs/server-chain.crt
#	scp -P 10022 ssl.conf $DIP:/etc/pki/tls/certs/server-chain.crt
#	rm -f server-chain.crt
#fi
