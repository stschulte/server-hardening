Harden::Rule.add("cis-1.1.6", :scored => true) do
  desc "Bind Mount the /var/tmp directory to /tmp"

  check "if /var/tmp is a bind mount" do
    bindmount? '/var/tmp', '/tmp'
  end
end
