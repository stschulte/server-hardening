require 'find'

Harden::Rule.add('cis-1.1.17', :scored => true) do
  desc "Set Sticky Bit on All World-Writable Directories"

  @directories = []

  check "for world-writeable directories" do
    Find.find('/') do |path|
      if FileTest.directory?(path) and (File.stat(path).mode & 01002) == 00002
        @directories << path
      end
    end
    @directories.empty?
  end

  fix "set sticky bit on directories" do
    @directories.each do |dir|
      old_mode = File.stat(dir).mode & 07777
      new_mode = old_mode | 01000
      puts "  * fixing #{dir} (0#{old_mode.to_s(8)} -> 0#{new_mode.to_s(8)})"
      File.chmod(new_mode, dir)
    end
  end
end
