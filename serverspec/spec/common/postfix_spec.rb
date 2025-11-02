require 'spec_helper'

describe package('postfix') do
  it { should be_installed.with_version('2.11.1-0') }
end

describe service('postfix') do
  it { should be_enabled }
end

# task 8475
describe file('/etc/postfix/main.cf') do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 644 }
  its(:md5sum) { should eq(property[:postfix_main_cf] || 'eeaeee38838b3a623faaefe3dcae44fc') }
end
