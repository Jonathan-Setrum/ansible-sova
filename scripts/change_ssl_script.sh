#!/bin/sh

file_time=`date +%Y%m%d%H%M%S`
host_name=$(hostname)

function get_file {
  echo "### get the ssl file ###"
  file_array=("ssl key" "cert" "intermediate cert" "csr")
  y=0
  for i in "${file_array[@]}"
  do
    while [ ! -n "${ans[y]}" ]
    do
      echo -n "Please enter the path of [$i file] :"
      read ans[y]
      if [ ! -n "${ans[y]}" ] ; then
        if [ "$i" = "intermediate cert" ] ; then
          ans[y]="1"
        elif [ "$i" = "csr" ] ; then
          ans[y]="1"
        else
          echo "* Please enter the file information."
        fi
      elif [ ! -e ${ans[y]} ] ; then
        echo "* [${ans[y]}] NOT found."
        echo "* Please enter the file information again."
        ans[y]=""
      elif [ ! -f ${ans[y]} ] ; then
        echo "* [${ans[y]}] is NOT a file."
        echo "* Please enter the file information again."
        ans[y]=""
      fi
    done
  y=$y+1
  done
 
  ssl_key_file=${ans[0]}
  cert_file=${ans[1]}
  intermediate_cert_file=${ans[2]}
  csr_file=${ans[3]}
}

function check_file {
  echo "### check the ssl file ###"
  cert_file_md5=`openssl x509 -noout -modulus -in $cert_file | openssl md5`
  if [ "`echo $?`" != "0" ] ; then
    echo "cert file is incorrect."
    exit
  fi
  ssl_key_file_md5=`openssl rsa -noout -modulus -in $ssl_key_file | openssl md5`
  if [ "`echo $?`" != "0" ] ; then
    echo "key file is incorrect."
    exit
  fi
  if [ "$cert_file_md5" != "$ssl_key_file_md5" ] ; then
    echo "ssl file is incorrect."
    exit
  fi

}

function copy_ssl_file {
  echo "### copy the ssl file to the configuration path ###"
  # backup ssl file
  ssl_file_array=("/etc/pki/tls/private/$host_name.key" "/etc/pki/tls/certs/$host_name.crt" "/etc/pki/tls/certs/$host_name-intermediate.crt" "/etc/pki/tls/certs/$host_name.csr")
  for i in "${ssl_file_array[@]}"
  do
    if [ -e $i ] ; then
      \cp -f $i $i.$file_time
    fi
  done
  
  # copy ssl file 
  \cp -f $ssl_key_file /etc/pki/tls/private/$host_name.key
  \cp -f $cert_file /etc/pki/tls/certs/$host_name.crt

  if [ "$intermediate_cert_file" != "1" ] ; then
    \cp -f $intermediate_cert_file /etc/pki/tls/certs/$host_name-intermediate.crt
  fi

  if [ "$csr_file" != "1" ] ; then
    \cp -f $csr_file /etc/pki/tls/certs/$host_name.csr
  fi
}
  
function set_ssl {
  echo "### setting the ssl file to the httpd configuration ###"
  # backup and set ssl.conf
  \cp -f /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.$file_time
  sed -i -e "s/localhost.crt/$host_name.crt/g" /etc/httpd/conf.d/ssl.conf  
  sed -i -e "s/localhost.key/$host_name.key/g" /etc/httpd/conf.d/ssl.conf  

  if [ "$intermediate_cert_file" != "1" ] ; then
    sed -i -e "s/server-chain.crt/$host_name-intermediate.crt/g" /etc/httpd/conf.d/ssl.conf  
  else
    sed -i -e "s/^SSLCertificateChainFile/#SSLCertificateChainFile/g" /etc/httpd/conf.d/ssl.conf  
  fi
}

function service_restart {
  echo "### service httpd configtest and restart###"
  service httpd configtest
  if [ "`echo $?`" = "0" ] ; then
    service httpd restart
  else
    \cp -f /etc/httpd/conf.d/ssl.conf.$file_time /etc/httpd/conf.d/ssl.conf
    echo "* The operation failed.Configuration file it was returned to the original."
    echo "* Please check the file again."
  fi
}

get_file
#check_file
#copy_ssl_file
#set_ssl
#service_restart

