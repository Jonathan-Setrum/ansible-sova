require 'spec_helper'

# **** bash ****
describe package('bash') do
  it { should be_installed.with_version('4.1.2-33.el6_7.1') }
end

# **** glibc ****
describe package('glibc') do
  it { should be_installed.with_version('2.12-1.166.el6_7.7') }
end

# **** resolve.conf ****
describe file('/etc/resolv.conf') do
  its(:md5sum) { should eq '85f9e16ab8d04744831456e202747265' }
end

# **** openssl ****
describe package('openssl') do
  it { should be_installed.with_version('1.0.1e-42.el6_7.4') }
end

# **** logrotate ****
describe file('/etc/logrotate.conf') do
  its(:md5sum) { should eq '7fd3c7d44ddb89ca52564c641d6a396b' }
end

# **** check command or file permission ****
describe file('/usr/bin/which') do
  it { should be_mode 755 }
end

describe file('/usr/bin/unzip') do
  it { should be_mode 700 }
end

describe file('/usr/bin/zipinfo') do
  it { should be_mode 700 }
end

describe file('/usr/bin/wget') do
  it { should be_mode 000 }
end
