require 'spec_helper'

describe file('/etc/httpd/conf.d/phpMyAdmin.conf') do
  it { should_not exist }
end
