require 'harden/template/mountoption'

Harden::Rule.add("cis-1.1.3", :scored => true) do
  template :mountoption, :path => '/tmp', :option => 'nosuid'
end
