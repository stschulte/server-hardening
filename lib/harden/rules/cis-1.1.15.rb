require 'harden/template/mountoption'

Harden::Rule.add('cis-1.1.15', :scored => true) do
  template :mountoption, :path => '/dev/shm', :option => 'nosuid'
end
