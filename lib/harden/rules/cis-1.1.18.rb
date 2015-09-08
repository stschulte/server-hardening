require 'harden/template/kernelmodule'

Harden::Rule.add('cis-1.1.18', :scored => false) do
  template :kernelmodule, :module => 'cramfs'
end
