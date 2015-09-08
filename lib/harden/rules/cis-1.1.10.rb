require 'harden/template/mountoption'

Harden::Rule.add('cis-1.1.10', :scored => true) do
  template :mountoption, :path => '/home', :option => 'nodev'
end
