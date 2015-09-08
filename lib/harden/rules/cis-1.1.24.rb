require 'harden/template/kernelmodule'

Harden::Rule.add('cis-1.1.24', :scored => false) do
  template :kernelmodule, :module => 'udf'
end
