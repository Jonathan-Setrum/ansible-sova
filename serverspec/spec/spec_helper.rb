require 'serverspec'
require 'net/ssh'
require 'yaml'

set :backend, :ssh

properties = YAML.load_file('properties.yml')

def library_version
  @versions ||= YAML.load_file(File.dirname(__FILE__) + "/version.yml")
end

RSpec.configure do |c|
  # Get IP from filename, such as `output/127.0.0.1.xml`
  file = c.formatters.find{|f| f.is_a?(RSpecJUnitFormatter) }.output.path
  ip, _nil = File.basename(file).rpartition(".")

  set_property properties[ip]

  options = Net::SSH::Config.for(ip)
  options[:user] ||= Etc.getlogin

  set :host, ip
  set :ssh_options, options
end

# Disable sudo
set :disable_sudo, true

# Set environment variables
set :env, :LANG => 'C', :LC_MESSAGES => 'C' 

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'

