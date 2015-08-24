Harden::Rule.add("cis-1.1.5", :scored => true) do
  desc "Create Separate Partition for /var"

  check "if /var is on a seperate partition" do
    mountpoint? '/var'
  end
end
