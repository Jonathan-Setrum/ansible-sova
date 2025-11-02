require 'spec_helper'

describe file("/etc/httpd/conf.d/performance.conf") do
  let(:checksum) do
    if property[:httpd_performance_conf]
      property[:httpd_performance_conf]
    elsif property[:boost]
    # FIXME: Add boost attribute to properties.yml
      "1b072b17640a890fd47d9320a69e59f3"
    else
      case property[:plan]
      when "Wordpress-Free"
        "45711ce63e0abb8466feb52314da8e93"
      when "Wordpress-Small"
        "45711ce63e0abb8466feb52314da8e93"
      when "Wordpress-Medium"
        "83566df9245dba922529f9d605ac3deb"
      when "Wordpress-Large"
        "ab88837f0542363aa733404262e4b5c6"
      when "Wordpress-Premium"
        "d3c4e8421b55076379e2021a1352d117"
      else
        raise ArgumentError, "Unknown plan: '#{property[:plan]}'"
      end
    end
  end
  its(:md5sum) { should eq(checksum) }
end

describe file('/var/www') do
  it { should be_grouped_into 'root' }
  it { should be_owned_by 'root' }
  it { should be_mode 755 }
end

describe file('/var/www/html') do
  it { should be_grouped_into 'sova' }
  it { should be_owned_by "#{property[:sftpuser]}" }
  it { should be_mode 755 }
end

