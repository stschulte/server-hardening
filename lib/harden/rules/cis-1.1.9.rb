require 'harden/template/mountpoint'

Harden::Rule.add('cis-1.1.9', :scored => true) do
  template :mountpoint, :path => '/home'
end
