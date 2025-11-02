require 'spec_helper'
# This specs are for whole phpMyAdmin package.  Should be run regardless of whether phpMyAdmin is enabled or not.

describe package('phpMyAdmin') do
  it { should be_installed.with_version(library_version["phpMyAdmin"]) }
end

describe file('/etc/phpMyAdmin') do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 755 }
end

describe file('/etc/phpMyAdmin/config.inc.php') do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 644 }
  its(:md5sum) { should eq '8cd5f8a08d556af580af21f1ef6701a9' }
end
