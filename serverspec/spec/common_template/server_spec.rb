require 'spec_helper'

# **** httpd ****
# TODO: Move to common group
describe file('/etc/httpd/conf/httpd.conf') do
  its(:md5sum) { should eq 'ba2e8f2795acb109197f129fcfb29768' }
end

# *** html ***
# 'html' should not exist
describe command('test -z "$(ls -A /var/www/ | grep -v -e phpMyAdmin)"') do
  its(:exit_status) { should eq 0 }
end

describe file('/root/html-ja/') do
  it { should be_owned_by 'sova' }
  it { should be_grouped_into 'sova' }
end
describe command("find /root/html-ja -ls | awk '{print $5}' | sort -u | wc -l") do
  its(:stdout) { should eq "1\n" }
end
describe command("find /root/html-ja -ls | awk '{print $6}' | sort -u | wc -l") do
  its(:stdout) { should eq "1\n" }
end
describe file('/root/html-ja/wp-config-sova.php') do
  it { should be_file }
end

describe file('/root/html-en/') do
  it { should be_owned_by 'sova' }
  it { should be_grouped_into 'sova' }
end
describe command("find /root/html-en -ls | awk '{print $5}' | sort -u | wc -l") do
  its(:stdout) { should eq "1\n" }
end
describe command("find /root/html-en -ls | awk '{print $6}' | sort -u | wc -l") do
  its(:stdout) { should eq "1\n" }
end
describe file('/root/html-en/wp-config-sova.php') do
  it { should be_file }
end

# **** varnish ****
# TODO: Move to common group
describe file('/etc/sysconfig/varnish') do
  its(:md5sum) { should eq 'b7126052366adb6392ccfcfd10da436d' }
end

# **** mariadb ****
# TODO: Move to common group
describe file('/etc/my.cnf') do
  its(:md5sum) { should eq 'ae873e9306d052531b9b75e9559deccf' }
end

# TODO: Move to common group
describe file('/etc/my.cnf.d/server.cnf') do
  its(:md5sum) { should eq '3440d13e4ef9dd81aa71405277932e93' }
end

# **** check /etc/rc.d/rc.local contents ****
describe file('/etc/rc.d/rc.local') do
  it { should contain 'sh /root/scripts/salts2.sh' }
  it { should contain 'zabbix_agentd.conf' }
  its(:md5sum) { should eq 'd8be0a1ccab7415021e296a7943905b6' }
end

# **** MySQL ****
describe "mysql" do
  describe command(%{service mysql start >/dev/null;
  mysql -uroot --password=$(cat /root/scripts/root.passwd) --skip-column-names -B \
  -e 'SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM information_schema.SCHEMATA S WHERE SCHEMA_NAME="wordpress";';
  service mysql stop >/dev/null;}) do
    its(:stdout) { should eq "utf8\tutf8_general_ci\n" }
  end
end
