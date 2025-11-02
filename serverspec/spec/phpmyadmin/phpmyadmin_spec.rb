require 'spec_helper'

describe file('/etc/httpd/conf.d/phpMyAdmin.conf') do
  its(:md5sum) { should eq 'b56676ee9bc2d23fb14fd382a80ce4b3' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end
