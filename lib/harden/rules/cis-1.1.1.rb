require 'harden/template/mountpoint'

Harden::Rule.add("cis-1.1.1", :scored => true, :reboot => true) do
  template :mountpoint, :path => '/tmp'
end
