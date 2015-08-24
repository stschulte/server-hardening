Harden::Rule.add("cis-1.1.4", :scored => true) do
  desc "Set noexec option for /tmp Partition"

  check "if /tmp mounted with \"noexec\" option" do
    mountoptions? '/tmp', 'noexec'
  end

  fix "remount /tmp with \"noexec\" option" do
    add_mountoptions '/tmp', 'noexec'
    remount '/tmp'
  end
end
