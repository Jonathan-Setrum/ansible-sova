require 'spec_helper'

describe package('MariaDB-server') do
  it { should be_installed.with_version('5.5.45-1') }
end

describe service('mysql') do
  it { should be_enabled }
end
