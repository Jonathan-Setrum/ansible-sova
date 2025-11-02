require 'spec_helper'

describe package('zabbix-agent') do
  it { should be_installed.with_version('2.2.11-1') }
end

describe service('zabbix-agent') do
  it { should be_enabled }
end

describe file('/etc/zabbix/zabbix_agentd.conf') do
  let(:file_checksum) do
    if property[:plan] == "Wordpress-Free"
      '864893230ef2d658e0d6b8efeb3801f9'
    else
      '5f908fca2310a58ccc9ca8ff48a19d1c'
    end
  end

  its(:md5sum) { should eq file_checksum }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 644 }
end

describe file('/etc/zabbix/zabbix_agentd.d') do
  it { should be_directory }
end

# task 8365
describe file('/etc/zabbix/zabbix_agentd.d/check_html_disk_size.conf') do
  its(:md5sum) { should eq '1a4a899021b364ee5e68d76aa8b9d4ce' }
end
