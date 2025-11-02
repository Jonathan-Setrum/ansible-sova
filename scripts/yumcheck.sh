#!/bin/bash
if [ "$1" == '-v' ]; then
  package=$2
  nopatch=false
else
  nopatch=true
  package=$1
fi
if [ -z "$package" ]; then
  echo "[ERROR] need package_name"
  exit 1
fi

if [ -z "$HOST" ]; then
  HOST=182.48.4.10 # sova-template01
fi

# Check new version
version=$(ssh $HOST "yum -d 0 list updates $package 2>/dev/null")
if [ -z "$version" ]; then
  # Check installed version
  version=$(ssh $HOST "yum -C -d 0 list $package")
  result_all=$?
  if [ "$result_all" -gt 0 ]; then
    echo "[ERROR] yum exists with ${result_all}"
    exit $result_all
  fi
  if [ -z "$version" ]; then
    echo "[ERROR] yum returns empty string"
    exit 1
  fi
fi
version=$(echo "$version" | tail -n1 | awk '{print $2}')
if $nopatch ; then
  version=$(echo "$version" | grep -o '^[0-9\.]*')
fi

# If the script is in infrastrcture repo
if [ -f $(dirname $0)/update_serverspec.sh ] ; then
  sh $(dirname $0)/update_serverspec.sh "$package" $version
else
  echo "Latest version of $package is $version"
fi
