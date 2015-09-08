require 'harden/template/kernelmodule'

Harden::Rule.add('cis-1.1.22', :scored => false) do
  template :kernelmodule, :module => 'hfsplus'
end
