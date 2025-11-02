require 'spec_helper'

describe file('/root/sova.ver') do
  it { should contain '1.1.17' }
end
