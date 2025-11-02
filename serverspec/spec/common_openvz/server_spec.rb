require 'spec_helper'

describe package('rpcbind') do
  it { should be_installed.with_version('0.2.0-11') }
end

describe service('rpcbind') do
  it { should be_enabled }
end

describe service('nfslock') do
  it { should be_enabled }
end

describe package('nfs-utils') do
  it { should be_installed.with_version('1.2.3-64') }
end

describe service('nfs') do
  it { should be_enabled }
end

describe file('/etc/exports') do
  its(:md5sum) { should eq '618092760a06b668b985fa237f09d608' }
end

describe file('/etc/sysconfig/iptables') do
  its(:md5sum) { should eq '9bfabca4cf12a1ddae29fa82a2d2b694' }
end
