require "yaml"

INPUT_FILE  = ENV.fetch("INPUT_FILE",  "#{Dir.pwd}/urls.yml")
OUTPUT_FILE = ENV.fetch("OUTPUT_FILE", "#{Dir.pwd}/serverspec/properties.yml")

# VM instances
sova_vms = YAML.load_file(INPUT_FILE).map!{|vm|
  vm[:roles] = ["common", "common_instance"]

  if vm[:plan] == "Wordpress-Free"
    vm[:roles] << "common_openvz"
    vm[:roles] << "openvz_instance"
  else
    vm[:roles] << "common_solusvm"
    vm[:roles] << "solusvm_instance"
  end
  vm[:roles] << (vm[:phpmyadmin] == "enable" ? "phpmyadmin" : "phpmyadmin_disabled")

  [vm[:ip], vm]
}
hosts = Hash[sova_vms]

open(OUTPUT_FILE, "w") {|f| f.puts hosts.to_yaml }
