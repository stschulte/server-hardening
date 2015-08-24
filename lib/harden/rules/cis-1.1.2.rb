Harden::Rule.add("cis-1.1.2", :scored => true) do
  desc "Set nodev option for /tmp Partition"

  check "if /tmp mounted with \"nodev\" option" do
    mountoptions? '/tmp', 'nodev'
  end

  fix "remount /tmp with \"nodev\" option" do
    add_mountoptions '/tmp', 'nodev'
    remount '/tmp'
  end
end
