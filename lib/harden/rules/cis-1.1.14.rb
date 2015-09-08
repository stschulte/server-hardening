require 'harden/template/mountoption'

Harden::Rule.add('cis-1.1.14', :scored => true) do
  template :mountoption, :path => '/dev/shm', :option => 'nodev'
end
