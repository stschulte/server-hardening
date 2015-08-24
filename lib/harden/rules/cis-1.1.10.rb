Harden::Rule.add('cis-1.1.10', :scored => true) do
  desc "Add nodev Option to /home"

  check "if /home is mounted with nodev" do
    mountoptions? '/home', 'nodev'
  end

  fix "remount /home with nodev" do
    add_mountoptions '/home', 'nodev'
    remount '/home'
  end
end
