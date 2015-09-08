module Harden::Template::Filesystemmodule
  def render(options)
    kernelmodule = options[:module]

    @description  ||= "Disable Mounting of #{kernelmodule} Filesystems"
    @check_msg    ||= "if #{kernelmodule} is disabled"
    @fix_msg      ||= "disable #{kernelmodule}"

    @check_code   ||= proc do
      # If the kernel module is currently loaded it cannot be disabled
      if kernelmodule_loaded? kernelmodule
        false
      else
        # If it is not loaded, pretend to load it and check if it is deactivated
        # in case the module is not present on the system, the command below will
        # fail
        res, output = execute('/sbin/modprobe', '-n', '-v', kernelmodule)

        # if we cannot load the module at all (e.g. not present on the system) it
        # can be seen as disabled
        res != 0 or %r{install\s*/bin/true}.match(output.chomp)
      end
    end

    @fix_code     ||= proc do
      content = []
      found = false

      if File.exist?("/etc/modprobe.d/CIS.conf")
        File.read("/etc/modprobe.d/CIS.conf").each_line do |line|
          if match = %r{^(\s*install\s*#{kernelmodule}\s*)(.*)$}.match(line)
            content << "#{match.captures[0]}/bin/true"
            found = true
          else
            content << line
          end
        end
      end

      unless found
        content << "install #{kernelmodule} /bin/true"
      end

      File.open("/etc/modprobe.d/CIS.conf", 'w') do |f|
        f.puts content.join("\n")
      end

      if kernelmodule_loaded? kernelmodule
        execute '/sbin/modprobe', '-r', kernelmodule
      end
    end
  end
end

Harden::Template.register(:kernelmodule, Harden::Template::Filesystemmodule)
