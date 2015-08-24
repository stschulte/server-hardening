Harden::Rule.add('cis-1.1.9', :scored => true) do
  desc "Create Separate Partition for /home"

  check "if /home is on a seperate partition" do
    mountpoint? '/home'
  end
end
