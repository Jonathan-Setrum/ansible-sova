#!/bin/bash -e
set -e

SCRIPT_DIR=$(dirname $0)

if [ -z "$HOST" ] ; then
  echo "[ERROR] HOST is not defined"
  exit 1
fi
: ${RAILS_ENV:="production"}

echo "Generate urls.yml on $HOST..."
ssh -o ConnectTimeout=10 $HOST "cd /srv/rails/sova/current ; RAILS_ENV=$RAILS_ENV bundle exec rails runner '$(cat $SCRIPT_DIR/get_vservers.rb)' > /dev/null"
exit_status=$?
if [ $exit_status -ne 0 ]; then
  exit $exit_status
fi
echo "Transfer urls.yml..."
scp -o ConnectTimeout=10 $HOST:/srv/rails/sova/shared/system/urls.yml .

if [ -f urls.yml ]; then
  echo "Complete urls.yml..."
  ruby scripts/format_urls_yml.rb
  echo "[SUCCESS] urls.yml successfuly generated"
else
  echo "[ERROR] urls.yml was not generated"
  exit 1
fi
