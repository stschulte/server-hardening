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

  def bindmount?(mntpoint, target)
    return false if mountpoint? mntpoint
    if fstab_entry = mountentry(:fstab, mntpoint)
      return false unless fstab_entry[0] == target and fstab_entry[3].split(',').include? 'bind'
    end
    if proc_entry = mountentry(:proc, mntpoint)
      return false unless  proc_entry[0] == target and proc_entry[3].split(',').include? 'bind'
    end
  end

  def remount(mntpoint)
    execute('/bin/mount', '-o', 'remount', mntpoint)
  end

  def mountentry(mntpoint, where)
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
      return fields if fields[1] == mntpoint
    end
    nil
  end

  def mountoptions(mntpoint, where)
    if entry = mountentry(mntpoint, where)
      entry[3]
    end
  end

  def mountoptions?(mntpoint, option)
    if fstab_options = mountoptions(mntpoint, :fstab) and proc_options = mountoptions(mntpoint, :proc)
      fstab_options.include? option and proc_options.include? option
    end
  end

  def kernelmodule_loaded?(kernel_module)
    res, output = execute('/sbin/lsmod')
    output.lines.find { |l| l.split(/\s+/).first == kernel_module }
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

  def execute(*command)
    unless File.executable? command[0]
      raise ArgumentError, "Command #{command[0]} is not executable"
    end

    out, child_out = IO::pipe
    err, child_err = IO::pipe
    output = ""

    unless (childpid = fork)
      out.close
      err.close
      $stdout.reopen(child_out)
      $stderr.reopen(child_err)
      child_out.close
      child_err.close
      ENV['LANG'] = ENV['LC_ALL'] = ENV['LC_MESSAGE'] = ENV['LANGUAGE'] = 'C'
      exec(*command)
      exit!
    end

    child_out.close
    child_err.close
    watch = [out,err]
    while(!watch.empty? and readable = IO.select(watch)[0]) do
      readable.each do |stream|
        if stream.eof?
          stream.close
          watch.delete(stream)
        else
          line = stream.readline
          if stream == out # capture stdout and eat stderr of child
            yield line if block_given?
            output += line
          end
        end
      end
    end

    out.close unless out.closed?
    err.close unless out.closed?
    [ Process.waitpid2(childpid)[1].to_i >> 8, output ]
  end
end
