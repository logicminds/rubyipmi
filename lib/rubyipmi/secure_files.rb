# frozen_string_literal: true

require 'tmpdir'

module Rubyipmi
  # Private directory and file helpers for credentials, logs, and diagnostics.
  # Files are created mode 0600 inside a per-uid directory mode 0700, and
  # symlinks are not followed.
  module SecureFiles
    module_function

    def private_runtime_dir
      dir = File.join(Dir.tmpdir, "rubyipmi-#{Process.uid}")
      begin
        Dir.mkdir(dir, 0o700)
      rescue Errno::EEXIST
        # The directory is checked for ownership and mode below.
      end

      stat = File.lstat(dir)
      unless stat.directory? && !stat.symlink? && stat.uid == Process.uid
        raise "Refusing to use #{dir}: expected a private directory owned by uid #{Process.uid}"
      end

      File.chmod(0o700, dir)
      stat = File.lstat(dir)
      raise "Refusing to use #{dir}: could not restrict permissions to 0700" unless (stat.mode & 0o777) == 0o700

      retire_legacy_tempfiles
      dir
    end

    # Older releases wrote these predictable paths with the process umask.
    # Remove a regular file we own so a previous log is not left behind.
    def retire_legacy_tempfiles
      names = ['rubyipmi.log', 'rubyipmi_diag_data.txt']
      dirs = [Dir.tmpdir, '/tmp'].uniq
      names.product(dirs).each do |name, directory|
        path = File.join(directory, name)
        stat = File.lstat(path)
        next unless stat.file? && stat.uid == Process.uid

        File.unlink(path)
      rescue Errno::ENOENT
        next
      end
    end

    def open_private(name, append: false)
      path = File.join(private_runtime_dir, name)
      flags = File::RDWR | File::CREAT
      flags |= File::APPEND if append
      flags |= File::NOFOLLOW if File.const_defined?(:NOFOLLOW)
      file = File.new(path, flags, 0o600)
      stat = file.stat
      unless stat.file? && stat.uid == Process.uid
        file.close
        raise "Refusing to use #{path}: expected a regular file owned by uid #{Process.uid}"
      end
      file.chmod(0o600)
      file.truncate(0) unless append
      file
    rescue Errno::ELOOP
      raise "Refusing to use #{path}: will not follow a symlink"
    end
  end
end
