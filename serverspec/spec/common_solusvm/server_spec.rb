require 'spec_helper'

describe file('/etc/security/access.conf') do
  its(:md5sum) { should eq '4fa7e2827449092bf28daebcb78c8e11' }
end

describe file('/etc/pam.d/sshd') do
  its(:md5sum) { should eq 'f05cbf5af26c88985db2903fd5783980' }
end

describe file('/etc/pam.d/crond') do
  its(:md5sum) { should eq '24bf2f01b79994dad566ebe380b976cb' }
end

describe file('/etc/sysconfig/iptables') do
  its(:md5sum) { should eq 'd92f9d660f4bad2bb3bbe22c9993f2c2' }
end
