#!/bin/bash

set -o errexit
set -o nounset

BACKUP_BASE=$HOME/ldap_backups
if [ ! -d $BACKUP_BASE ] ; then
    echo "Not found: $BACKUP_BASE" 1>&2
    exit 1
fi

DB_HOTBACKUP=`which db_hotbackup`

BACKUP_NAME=`date --rfc-3339=seconds`
BACKUP_DIR=${BACKUP_BASE}/${BACKUP_NAME}
[ ! -d "$BACKUP_DIR" ] && mkdir "$BACKUP_DIR"

LDAP_HOME=/var/lib/ldap
[ -d $LDAP_HOME ]
$DB_HOTBACKUP -h $LDAP_HOME -Dc -b "$BACKUP_DIR"

tar czvf "${BACKUP_DIR}.tar.gz" -C ${BACKUP_BASE} "${BACKUP_NAME}"
rm "$BACKUP_DIR"/*
rmdir "$BACKUP_DIR"
find ${BACKUP_BASE}/*.tar.gz -mtime +6 -exec rm {} \;
