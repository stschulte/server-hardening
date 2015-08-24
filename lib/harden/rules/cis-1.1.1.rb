Harden::Rule.add("cis-1.1.1", :scored => true) do
  desc "Create Separate Partition for /tmp"

  check "if /tmp is on a seperate partition" do
    mountpoint? '/tmp'
  end
end
