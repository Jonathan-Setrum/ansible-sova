require 'spec_helper'

describe package('php') do
  it { should be_installed.with_version(library_version["php"]) }
end

describe file('/usr/bin/php') do
  it { should be_mode 755 }
end

describe file('/etc/php.ini') do
  its(:md5sum) { should eq(property[:php_ini] || '7bffded0655d0a3e851482a1baab5d20') }
end

# Apache loads php.ini from root dir rather than /etc/php.ini.  The file should not exist.
describe file('/php.ini') do
  it { should_not exist }
end

describe file('/var/lib/php/session') do
  it { should be_grouped_into 'sova' }
  it { should be_owned_by (property[:sftpuser] || "sova") }
  it { should be_mode 770 }
end

describe file('/usr/share/php/prepend.php') do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 644 }
  its(:md5sum) { should eq 'abcc9d6aed78a53bd053c3aee2a01f46' }
end

describe file('/etc/php.d/suhosin.ini') do
  it { should_not exist }
end

describe file('/etc/php.d/xcache.ini') do
  it { should_not exist }
end

describe file('/etc/php.d/40-xcache.ini') do
  its(:md5sum) { should eq 'fd7571df4bb3bf2914e8f01c3f3f3b00' }
end
