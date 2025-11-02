require 'spec_helper'

describe package('varnish') do
  it { should be_installed.with_version('3.0.7') }
end

describe service('varnish') do
  it { should be_enabled }
end
