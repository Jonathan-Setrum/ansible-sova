require 'spec_helper'

# **** check /root/scripts/* exsists ****
describe file('/root/scripts/salts2.sh') do
  its(:md5sum) { should eq '6d88c6e5225fe22d29bcd7ce6624c498' }
end

describe file('/root/scripts/sova.sh') do
  its(:md5sum) { should eq '0ba03d1af3146350566b39bcc9845161' }
end

describe file('/root/scripts/sova.passwd') do
  its(:md5sum) { should eq '5d7eea8d1e675c9cab5c7dd75cdc6e54' }
  it { should contain 'S0v4' }
end

describe file('/root/scripts/old_sova.passwd') do
  its(:md5sum) { should eq '5d7eea8d1e675c9cab5c7dd75cdc6e54' }
  it { should contain 'S0v4' }
end

describe file('/root/scripts/mysql.passwd') do
  its(:md5sum) { should eq '5d7eea8d1e675c9cab5c7dd75cdc6e54' }
  it { should contain 'S0v4' }
end

describe file('/root/scripts/root.passwd') do
  its(:md5sum) { should eq 'bcf89db3997a3b69e2d2d66a4bb27ebc' }
  it { should contain '48l2' }
end

describe file('/root/scripts/httpd1gb.conf') do
  its(:md5sum) { should eq 'f5d0b796878baa1849f476096b23e7eb' }
end

describe file('/root/scripts/httpd4gb.conf') do
  its(:md5sum) { should eq 'f5d0b796878baa1849f476096b23e7eb' }
end

describe file('/root/scripts/httpd8gb.conf') do
  its(:md5sum) { should eq '09e318289cb2e11814cc8c4f7b1460a2' }
end

describe file('/root/scripts/server1gb.cnf') do
  its(:md5sum) { should eq '7405012f027e707c847bdd332089a9d3' }
end

describe file('/root/scripts/server4gb.cnf') do
  its(:md5sum) { should eq '7405012f027e707c847bdd332089a9d3' }
end

describe file('/root/scripts/server8gb.cnf') do
  its(:md5sum) { should eq '755bad44c5a806c6e52115e131d8d13a' }
end

describe file('/root/scripts/varnish1gb') do
  its(:md5sum) { should eq 'c7fd0d7c0add01730ee65b7b15368f93' }
end

describe file('/root/scripts/varnish4gb') do
  its(:md5sum) { should eq 'c7fd0d7c0add01730ee65b7b15368f93' }
end

describe file('/root/scripts/varnish8gb') do
  its(:md5sum) { should eq '7771318d7ef2a7eac95375c52f14415b' }
end

