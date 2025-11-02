require 'spec_helper'

describe package('httpd') do
  it { should be_installed.with_version('2.2.27') }
end

describe service('httpd') do
  it { should be_enabled }
end

describe file('/etc/logrotate.d/httpd') do
  its(:md5sum) { should eq '5fbe49546a75391f6184abe49951f4ee' }
end

### Remove default settings ###
describe file('/etc/httpd/conf.d/welcome.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/proxy_ajp.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/mod_security.conf') do
  it { should_not exist }
end

### SSL ###
describe file('/etc/pki/tls/certs/localhost.crt') do
  its(:md5sum) { should eq 'c9219416803a848bb79bfd7ae0fe4bf7' }
end

describe file('/etc/pki/tls/private/localhost.key') do
  its(:md5sum) { should eq '172f66420af3900596904ac5388cc686' }
end

describe file('/etc/pki/tls/certs/server-chain.crt') do
  its(:md5sum) { should eq '39fea827fb7bc95a49f74725eb6be3ee' }
end

# **** ssl.conf ****
# describe file('/etc/httpd/conf.d/ssl.conf') do
#  its(:md5sum) { should eq(property[:httpd_ssl_conf] || 'e5c4dccbe37544e004e5c613c3560843') }
# end
describe file('/etc/httpd/conf.d/ssl.conf') do
  its(:md5sum) { should eq '0382b4fb76b3a7a3d0f8983127abedf6' }
end

describe file('/etc/httpd/conf.d/vary.conf') do
  its(:md5sum) { should eq '8f8281bf70e05a09ef45ab0bb1385e26' }
end

describe file('/etc/httpd/conf.d/000-remoteip.conf') do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 644 }
  its(:md5sum) { should eq '8c2b0caea5a585d6c28bc1fb0362688a' }
end

describe file('/etc/httpd/modules/mod_remoteip.so') do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 755 }
end

## task 8178
describe file('/etc/httpd/conf.d/badbot.conf') do
  its(:md5sum) { should eq 'bf676e5b4ee51cc0579712aab39317ee' }
end
