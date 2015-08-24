Harden::Rule.add("cis-1.1.3", :scored => true) do
  desc "Set nosuid option for /tmp Partition"

  check "if /tmp mounted with \"nosuid\" option" do
    mountoptions? '/tmp', 'nosuid'
  end

  fix "remount /tmp with \"nosuid\" option" do
    add_mountoptions '/tmp', 'nosuid'
    remount '/tmp'
  end
end
