require 'harden/template/mountoption'

Harden::Rule.add('cis-1.1.16', :scored => true) do
  template :mountoption, :path => '/dev/shm', :option => 'noexec'
end
