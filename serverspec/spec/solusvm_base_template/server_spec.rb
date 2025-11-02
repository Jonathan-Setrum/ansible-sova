require 'spec_helper'

describe file('/root/sova.ver') do
  it { should contain '1.3.24' }
end

describe cron do
  it { should have_entry('5 0  * * * /root/scripts/backup.sh > /dev/null 2>&1').with_user('root') }
end
