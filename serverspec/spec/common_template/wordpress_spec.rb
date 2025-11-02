require 'spec_helper'

# library_version is defined in spec_helper
describe "WordPress original" do
  describe command(%{grep '\$wp_version =' /root/html-en/wp-includes/version.php | awk -F= '{ print $2 }' | grep -Eo "[\.0-9]+" | tr -d '\n'}) do
    its(:stdout) { should eq library_version["wp_en"] }
  end
end

describe "WordPress Japanese package" do
  describe command(%{grep '\$wp_version =' /root/html-ja/wp-includes/version.php | awk -F= '{ print $2 }' | grep -Eo "[\.0-9]+" | tr -d '\n'}) do
    its(:stdout) { should eq library_version["wp_ja"] }
  end
end
