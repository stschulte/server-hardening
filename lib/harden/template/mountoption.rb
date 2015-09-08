module Harden::Template::Mountoption
  def render(options)
    mntpoint = options[:path]
    mntoption = options[:option]
    @description  ||= "Add #{mntoption} Option to #{mntpoint}"
    @precheck_msg ||= "if #{mntpoint} is a mountpoint"
    @precheck_code ||= proc { mountpoint? mntpoint }
    @check_msg    ||= "if #{mntpoint} is mounted with #{mntoption}"
    @check_code   ||= proc do
      mountoptions? mntpoint, mntoption
    end
    @fix_msg      ||= "remount #{mntpoint} with #{mntoption}"
    @fix_code     ||= proc do
      add_mountoptions mntpoint, mntoption
      remount mntpoint
    end
  end
end

Harden::Template.register(:mountoption, Harden::Template::Mountoption)
