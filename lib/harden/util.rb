module Harden::Util
  def mountpoint?(mntpoint)
    File.read('/etc/fstab').each_line do |line|
      next if /^\s*#/.match(line)
      next if /^\s*$/.match(line)

      fields = line.split(/\s+/)
      path = fields[1]
      return true if path == mntpoint
    end
    false
  end

  def remount(mntpoint)
    %x[/bin/mount -o remount #{mntpoint}]
  end

  def mountoptions(mntpoint, where)
    file = case where
    when :fstab
      '/etc/fstab'
    else
      '/proc/self/mounts'
    end

    File.read(file).each_line do |line|
      next if /^\s*#/.match(line)
      next if /^\s*$/.match(line)

      fields = line.split(/\s+/)
      path = fields[1]
      options = fields[3]
      return options if path == mntpoint
    end
    nil
  end

  def mountoptions?(mntpoint, option)
    if fstab_options = mountoptions(mntpoint, :fstab) and proc_options = mountoptions(mntpoint, :proc)
      fstab_options.include? option and proc_options.include? option
    end
  end

  def add_mountoptions(mntpoint, option)
    new_content = []
    changed = false
    File.read('/etc/fstab').each_line do |line|
      line.chomp!
      case line.chomp!
      when /^\s*$/, /^\s*#/
        new_content << line
      else
        fields = line.split(/\s+/)
        if fields[1] == mntpoint
          options = fields[3].split(',')
          unless options.include? option
            unless options == [ 'defaults' ]
              options << option
            else
              options = [ option ]
            end
            fields[3] = options.join(',')
            changed = true
          end
          new_content << fields.join("\t")
        else
          new_content << line
        end
      end
    end

    if changed
      File.open('/etc/fstab', 'w') do |f|
        f.puts new_content.join("\n")
      end
    end
  end
end
