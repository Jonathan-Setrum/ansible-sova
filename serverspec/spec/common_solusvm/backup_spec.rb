require 'spec_helper'

# ansible/roles/sova_vm_update_s3cmd
describe file('/root/scripts/backup.sh') do
  its(:md5sum) { should eq 'ffe7a37a0c38d0e6d1218b16bcc759a4' }
end

describe file('/usr/bin/s3-cli') do
  it { should be_executable }
end

describe file('/root/.s3cfg') do
  its(:md5sum) { should eq '97bc0a11b81af514cc13fbaaf3998650' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 600 }
end

describe file('/backup') do
  it { should be_directory }
end
