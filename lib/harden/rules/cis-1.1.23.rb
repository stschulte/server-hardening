require 'harden/template/kernelmodule'

Harden::Rule.add('cis-1.1.23', :scored => false) do
  template :kernelmodule, :module => 'squashfs'
end
