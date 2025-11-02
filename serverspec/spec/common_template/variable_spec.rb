# These files are handled by rails-admin.  Should not exist by default.
describe file('/etc/httpd/conf.d/phpMyAdmin.conf') do
  it { should_not exist }
end

describe file('/etc/php.d/disable_functions.ini') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/user.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/performance.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/disable_xmlrpc.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/disable_comments.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/install_mode.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/disable_robots.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/ssl.d/disable_robots.conf') do
  it { should_not exist }
end

describe file('/etc/my.cnf.d/performance.cnf') do
  it { should_not exist }
end

describe file('/etc/sysconfig/varnish.ext') do
  it { should_not exist }
end

describe file('/etc/varnish/black_list.vcl') do
  it { should_not exist }
end

describe file('/etc/varnish/default.vcl') do
  it { should_not exist }
end

describe file('/etc/postfix/virtual') do
  it { should_not exist }
end

describe file('/etc/zabbix/zabbix_agentd.d/hostname.conf') do
  it { should_not exist }
end
