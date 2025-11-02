require 'spec_helper'

describe user("#{property[:sftpuser]}") do
  it { should have_uid 500 }
end

