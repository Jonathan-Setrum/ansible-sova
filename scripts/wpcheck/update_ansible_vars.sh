#!/bin/bash

ANSIBLE_NEW="ansible_config.txt"
ANSIBLE_BASE="ansible/group_vars/all"
SERVERSPEC="serverspec/spec/version.yml"

# ansible

python scripts/wpcheck/generate_ansible_config.py
if [ ! -f $ANSIBLE_NEW ]; then
  echo "[ERROR] $ANSIBLE_NEW is not generated."
  exit 1
fi

sed -e '/# BEGIN WordPress/,/# END WordPress/d' $ANSIBLE_BASE > $ANSIBLE_BASE.orig
cat $ANSIBLE_NEW > $ANSIBLE_BASE
cat $ANSIBLE_BASE.orig >> $ANSIBLE_BASE
rm -f $ANSIBLE_NEW $ANSIBLE_BASE.orig

# serverspec

ruby <<_EOS_
require "yaml"
all = File.expand_path("${ANSIBLE_BASE}")
spec = File.expand_path("${SERVERSPEC}")
yml = YAML.load_file(all)
version = {
  "wp_ja" => yml["wp_version_ja"].to_s,
  "wp_en" => yml["wp_version_en"].to_s
}
File.write(spec,
  YAML.load_file(spec).merge(version).to_yaml
)
_EOS_

if git diff --quiet; then
  echo "WP version already updated"
else
  git add $ANSIBLE_BASE $SERVERSPEC
  git commit -m "WordPress updated"
  if [ -n "$BUILD_NUMBER" ]; then
    # $GIT_BRANCH = origin/develop
    git push -u $(echo $GIT_BRANCH | sed "s/\// HEAD:/")
  else
    echo "Invoke next job manually, please."
  fi
fi
