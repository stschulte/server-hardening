require 'harden/template/mountoption'

Harden::Rule.add("cis-1.1.4", :scored => true) do
  template :mountoption, :path => '/tmp', :option => 'noexec'
end
