require 'harden/template/mountpoint'

Harden::Rule.add("cis-1.1.7", :scored => true) do
  template :mountpoint, :path => '/var/log'
end
