require 'harden/template/kernelmodule'

Harden::Rule.add('cis-1.1.20', :scored => false) do
  template :kernelmodule, :module => 'jffs2'
end
