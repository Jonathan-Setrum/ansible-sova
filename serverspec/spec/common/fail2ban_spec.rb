require 'spec_helper'

describe package('fail2ban') do
  it { should be_installed.with_version('0.9.3-1.el6.1') }
end

describe service('fail2ban') do
  it { should be_enabled }
end

describe file('/etc/logrotate.d/fail2ban') do
  its(:md5sum) { should eq '15333e50f1e700ee228dd75d7f03c277' }
end

### Action ###
describe file('/etc/fail2ban/fail2ban.conf') do
  its(:md5sum) { should eq '02d10b96bad8f892d621df67a8626465' }
end

describe file('/etc/fail2ban/jail.conf') do
  its(:md5sum) { should eq '423ef1080f0e0995c2a993e0b5325127' }
end

describe file('/etc/fail2ban/action.d/iptables-blocktype.conf') do
  its(:md5sum) { should eq '315d860742e056e4b1a2b8f6867f9f10' }
end
describe file('/etc/fail2ban/action.d/report_banip.conf') do
  its(:md5sum) { should eq '3247dcb0f7fb103ad0aec96545815d7a' }
end

### Filter ###
# should not exist
describe file('/etc/fail2ban/filter.d/wordpress-comment.conf') do
  it { should_not exist }
end

describe file('/etc/fail2ban/filter.d/wordpress-spam.conf') do
  its(:md5sum) { should eq '35dc52fe4e4f8c85cdf5034a6ae4adae' }
end
describe file('/etc/fail2ban/filter.d/wordpress-dos.conf') do
  its(:md5sum) { should eq '49f544d79ef462e1065dd2b8631ff649' }
end
describe file('/etc/fail2ban/filter.d/wordpress-login.conf') do
  its(:md5sum) { should eq 'e82b6faf94d165c64890ec67fc9f44d3' }
end
describe file('/etc/fail2ban/filter.d/wordpress.conf') do
  its(:md5sum) { should eq '77032de191570c331bbdc6636c0ecf0a' }
end

## task 8370
describe file('/etc/httpd/conf.d/httpd_fail2ban_post.conf') do
  its(:md5sum) { should eq '61a6fa48d61c1e21d30e3cfe6ca64e67' }
end
