#!/bin/bash

# $0 is the name of the command
# $1 first parameter
# $# total number of parameters
# $@ all the parameters will be listed
# echo $0

if [ "$#" -ne 2 ];
then
	echo 'Ensure that the following files (rename if necessary) are in the same folder as the script'
	echo '1. Certificate: public.crt '
	echo '2. Key: private.key '
	echo '3. Intermediate Cert: server-chain.crt '
	echo 'Usage deploy_cert.sh IPAddress DomainName'
	exit
fi

DOMAIN_IP='www.example.com'
DOMAIN_IP=$1
DOMAIN_NAME=$2

echo $DOMAIN_IP $DOMAIN_NAME 
#exit;


# localhost.crt
scp -P 10022 $DOMAIN_NAME/public.crt $DOMAIN_IP:/etc/pki/tls/certs/
# ?.crt
## CHANGED 7610 NOT NEEDED
scp -P 10022 $DOMAIN_NAME/server-chain.crt $DOMAIN_IP:/etc/pki/tls/certs/
# localhost.key
scp -P 10022 $DOMAIN_NAME/private.key $DOMAIN_IP:/etc/pki/tls/private/

ssh -t $DOMAIN_IP "cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.0"
ssh -t $DOMAIN_IP "sed -i -e 's|#DocumentRoot|DocumentRoot|g' /etc/httpd/conf.d/ssl.conf"
ssh -t $DOMAIN_IP "sed -i -e 's|#ServerName www.example.com:443|ServerName $DOMAIN_NAME|g' /etc/httpd/conf.d/ssl.conf"
ssh -t $DOMAIN_IP "sed -i -e 's|SSLCertificateFile /etc/pki/tls/certs/localhost.crt|SSLCertificateFile /etc/pki/tls/certs/public.crt|g' /etc/httpd/conf.d/ssl.conf"
ssh -t $DOMAIN_IP "sed -i -e 's|SSLCertificateKeyFile /etc/pki/tls/private/localhost.key|SSLCertificateKeyFile /etc/pki/tls/private/private.key|g' /etc/httpd/conf.d/ssl.conf"
## CHANGED 7610 ssh -t $DOMAIN_IP "sed -i -e 's|#SSLCertificateChainFile /etc/pki/tls/certs/server-chain.crt|SSLCertificateChainFile /etc/pki/tls/certs/intermediate.crt|g' /etc/httpd/conf.d/ssl.conf"
ssh -t $DOMAIN_IP "sed -i -e 's|#SSLCertificateChainFile /etc/pki/tls/certs/server-chain.crt|SSLCertificateChainFile /etc/pki/tls/certs/server-chain.crt|g' /etc/httpd/conf.d/ssl.conf"
ssh -t $DOMAIN_IP "service httpd restart"

