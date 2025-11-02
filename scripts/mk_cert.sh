#!/bin/bash

# $0 is the name of the command
# $1 first parameter
# $# total number of parameters
# $@ all the parameters will be listed
# echo $0

DOMAIN_NAME='www.example.com'

function clean_files_ckey {
#	rm -rf *.key
#	rm -rf *.csr
	echo start...
}

function clean_files_temp {
	rm -rf myssl.cnf
##	rm -rf server.crt
##	rm -rf sha1.dat
}


clean_files_temp
if [ "$#" -ne 1 ];
then
	echo 'No Domain Name Entered As Argument. Cleaning Old Cert & Key Files.'
	clean_files_ckey
	exit
fi


DOMAIN_NAME=$1

# may fail if already exists
# mkdir $DOMAIN_NAME

# echo $DOMAIN_NAME.csr

#C = SG
#ST = Singapore
#L = Singapore
#O = Sova
#OU = SSL
#CN = $1


##echo server.crt  > server.crt 
##openssl sha256 * > sha256.dat
# exit
##cat sha256.dat
##openssl genrsa -out $DOMAIN_NAME.key -rand sha256.dat 2048
cat >> myssl.cnf <<EOF
[ req ]
prompt = no
distinguished_name = req_distinguished_name
 
[ req_distinguished_name ]
0.organizationName			= Sova
organizationalUnitName			= SSL
emailAddress				= dev@sova.sg
localityName				= Singapore
stateOrProvinceName			= Singapore
countryName				= SG
commonName				= $DOMAIN_NAME
EOF
#openssl req -new -key $DOMAIN_NAME.key -out $DOMAIN_NAME.csr
##openssl req -config myssl.cnf -new -key $DOMAIN_NAME.key -out $DOMAIN_NAME.csr


openssl genrsa -out $DOMAIN_NAME.key 2048
openssl req -config myssl.cnf -new -sha256 -key $DOMAIN_NAME.key -out $DOMAIN_NAME.csr

openssl req -in $DOMAIN_NAME.csr -noout -text

mkdir $DOMAIN_NAME
mv $DOMAIN_NAME.key $DOMAIN_NAME
mv $DOMAIN_NAME.csr $DOMAIN_NAME

# clean up
clean_files_temp
