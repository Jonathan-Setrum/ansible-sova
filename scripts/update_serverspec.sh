#!/bin/bash

varname=$1
version=$2

if [ -z $varname ] || [ -z $version ]; then
  echo "$0 name_of_variable version"
  exit 1
fi

SERVERSPEC="serverspec/spec/version.yml"

ruby <<_EOS_
require "yaml"

spec = File.expand_path("${SERVERSPEC}")
File.write(spec,
  YAML.load_file(spec).merge({ "${varname}" => "${version}" }).to_yaml
)
_EOS_

if git diff --quiet $SERVERSPEC ; then
  echo "${varname} version already updated"
else
  git add $SERVERSPEC
  git commit -m "${varname} ${version} has been released"
  if [ -n "$BUILD_NUMBER" ]; then # During jenkins job
    # $GIT_BRANCH = origin/develop
    git push -u $(echo $GIT_BRANCH | sed "s/\// HEAD:/")
  else
    echo "Invoke next job manually, please."
  fi
fi
