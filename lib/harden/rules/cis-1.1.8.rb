Harden::Rule.add("cis-1.1.8", :scored => true) do
  desc "Create Separate Partition for /var/log/audit"

  check "if /var/log/audit is on a seperate partition" do
    mountpoint? '/var/log/audit'
  end
end
