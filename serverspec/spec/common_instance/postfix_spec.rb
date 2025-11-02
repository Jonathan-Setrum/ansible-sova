require 'spec_helper'

unless property[:postfix_main_cf]
  describe file('/etc/postfix/virtual') do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
    it { should contain 'root@localhost' }
  end
end
