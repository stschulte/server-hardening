require 'harden/template/kernelmodule'

Harden::Rule.add('cis-1.1.19', :scored => false) do
  template :kernelmodule, :module => 'freevxfs'
end
