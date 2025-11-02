#!/bin/bash
template_vm=/vz/private/100
template_ver=`head -n 1 $template_vm/root/sova.ver | cut -d " " -f 1`
template_openvz=/vz/template/cache
template_jp=sovafree-wordpress-ja.tar.gz
template_en=sovafree-wordpress-en.tar.gz
newtemplate_jp=sovafree-wordpress-ja-$template_ver.tar.gz
newtemplate_en=sovafree-wordpress-en-$template_ver.tar.gz
bktemplate_jp=sovafree-wordpress-ja-$template_ver.tar.gz.`date +%Y%m%d%H%M`
bktemplate_en=sovafree-wordpress-en-$template_ver.tar.gz.`date +%Y%m%d%H%M`
local_bk=/root/sova-vm-filebk/10.1.53.100


sova_host_test=("10.1.53.2")
sova_host=("10.1.20.230" "10.1.21.230" "10.1.22.230")

# argument:1 do "Create new template to /vz/template/vz"
arg_1="create new template to /vz/template/vz"
# argument:2 do "Send new template to dadmin all server"
arg_2="send new template to dadmin all server"
# argument:3 do "Send new template to admin all server"
arg_3="send new template to admin all server"
# argument:4 do "In order to be able to create the same version, move the current version"
arg_4="In order to be able to create the same version, move the current version"

# check argument
if [ "$#" = "0" ];then
	echo "error: Please enter the argument."
	exit 0
fi

# Run work
for ANS in $@
do

	# Check file
	for var in $template_openvz/$template_jp $template_openvz/$template_en $template_vm/root/sova.ver
	do
		if [ ! -e $var ]; then
			echo "error: $var Not found ."
			exit 0
		fi
	done

	# create new template to /vz/template/vz
	if [ "$ANS" = "1" ]; then

		# check version exists
		for var in $template_openvz/$newtemplate_jp $template_openvz/$newtemplate_en
		do
			if [ -e $var ]; then
				echo "error: $var because it exists, it is not possible to create the same version."
				exit 0
			fi
		done

		# Stop varnish,httpd,mysql service
		for var in varnish httpd mysql nfs nfslock rpcbind
		do
			vzctl exec 100 service $var stop
		done

                # Delete history
                echo '' > $template_vm/root/.bash_history

                # Delete Log
		rm -f $template_vm/var/lib/php/session/*
		rm -f $template_vm/var/lib/varnish/*
		rm -f $template_vm/var/log/*
		rm -f $template_vm/var/log/zabbix/*
		rm -f $template_vm/var/log/varnish/*
		rm -f $template_vm/var/log/rkhunter/*
		rm -f $template_vm/var/log/mail/*
		rm -f $template_vm/var/log/httpd/*
		rm -f $template_vm/var/lib/mysql/ib_logfile[01]
		rm -f $template_vm/var/lib/mysql/OpenVZ.err
		rm -f $template_vm/var/lib/mysql/OpenVZ.sova.jp.err
		rm -f $template_vm/var/lib/mysql/VPS02.err
		rm -f $template_vm/var/lib/mysql/sova-template01.err
		rm -f $template_vm/var/lib/mysql/sovafree-template01.err
		cat /dev/null > $template_vm/var/mail/root
		rm -f $template_vm/var/mail/s*
		vzctl exec 100 yum clean all
		rm -rf $template_vm/tmp/*
		touch $template_vm/var/log/lastlog

                # mv /root/html-ja_*,/root/html-en_* to local_bk
                for var in $template_vm/root/html-ja_* $template_vm/root/html-en_*
                do
                        mv $var $local_bk/
                done

		# Check /root/html-ja,/root/html-en,/var/www/html
        	for var in $template_vm/root/html-ja $template_vm/root/html-en
        	do
                	if [ ! -e $var ]; then
                		if [ -e $template_vm/var/www/html ]; then
					mv $template_vm/var/www/html $var
				else
                        		echo "error: $var Not found ."
                        		exit 0
				fi
                	fi
        	done
	
		# new ja version
		mv $template_vm/root/html-ja $template_vm/var/www/html
		mv $template_vm/root/html-en $local_bk/html-en-bktemplate
		cd $template_vm
		tar --numeric-owner -czf /vz/template/cache/$newtemplate_jp .
		mv $template_vm/var/www/html $template_vm/root/html-ja
                mv $local_bk/html-en-bktemplate $template_vm/root/html-en

		# new en version
		mv $template_vm/root/html-en $template_vm/var/www/html
                mv $template_vm/root/html-ja $local_bk/html-ja-bktemplate
		cd $template_vm
		tar --numeric-owner -czf /vz/template/cache/$newtemplate_en .	
		mv $template_vm/var/www/html $template_vm/root/html-en
                mv $local_bk/html-ja-bktemplate $template_vm/root/html-ja

		# apply the new version
		cp $template_openvz/$newtemplate_jp $template_openvz/$template_jp
		cp $template_openvz/$newtemplate_en $template_openvz/$template_en
		echo "info: $arg_1 is finished."
	fi

	#set new template to dadmin all server 
	if [ "$ANS" = "2" ]; then

		for i in "${sova_host_test[@]}"
		do
			scp -P 22 $template_openvz/$template_jp $template_openvz/$template_en root@$i:$template_openvz/
		done
		echo "info: $arg_2 is finished."
	fi

	#set new template to admin all server 
	if [ "$ANS" = "3" ]; then

		for i in "${sova_host[@]}"
		do
			scp -P 22 $template_openvz/$template_jp $template_openvz/$template_en root@$i:$template_openvz/
		done
		echo "info: $arg_3 is finished."
	fi

	#set new template to admin all server 
	if [ "$ANS" = "4" ]; then

		mv $template_openvz/$newtemplate_jp $template_openvz/$bktemplate_jp
		mv $template_openvz/$newtemplate_en $template_openvz/$bktemplate_en
		echo "info: $arg_4 is finished."
	fi
done


