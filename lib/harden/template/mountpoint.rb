module Harden::Template::Mountpoint
  def render(options)
    mntpoint = options[:path]
    @require_reboot = true
    @description ||= "Create Separate Partition for #{mntpoint}"
    @check_msg   ||= "if #{mntpoint} is a seperate mountpoint"
    @check_code  ||= proc { mountpoint? mntpoint }
  end
end

Harden::Template.register(:mountpoint, Harden::Template::Mountpoint)
