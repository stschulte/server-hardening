require 'harden/template/mountoption'

Harden::Rule.add("cis-1.1.2", :scored => true) do
  template :mountoption, :path => '/tmp', :option => 'nodev'
end
