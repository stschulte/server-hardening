require 'harden/template/kernelmodule'

Harden::Rule.add('cis-1.1.21', :scored => false) do
  template :kernelmodule, :module => 'hfs'
end
