module MCB
  LOGGER = Logger.new($stdout)

  LOGGER.formatter = proc do |severity, _datetime, _progname, msg|
    if severity == Logger::INFO
      msg + "\n"
    else
      "#{severity}: #{msg}\n"
    end
  end

  # Load the rails environment.
  #
  # Not all mcb commands require the rails env, e.g. the API ones don't. Use
  # this method in those commands that do.
  def self.init_rails
    unless defined?(Rails)
      app_root = File.expand_path(File.join(File.dirname($0), '..'))
      exec_path = File.join(app_root, 'bin', 'rails')
      exec(exec_path, 'runner', $0, *ARGV)
    end
  end

  # Load commands from dir adding them to cmd
  #
  # Recursively load all the commands in a dir creating a structure of commands
  # and sub-commands. Each sub-directory must have a file in it's parent dir
  # with the same name which defines the parent command to the sub-commands in
  # that sub-directory.
  def self.load_commands(cmd, dir)
    directories = Pathname.new(dir).each_child.select(&:directory?)
    files = Pathname.new(dir).each_child.select(&:file?)

    commands = {}

    files.each do |path|
      new_cmd = Cri::Command.load_file(path.to_s, infer_name: true)
      commands[path.basename('.rb').to_s] = new_cmd
      cmd.add_command(new_cmd)
    end

    directories.each do |path|
      sub_command = commands[path.basename.to_s]
      if sub_command.nil?
        raise "Command #{path}.rb must be defined to have sub-commands #{path}"
      end

      load_commands(sub_command, path.to_s)
    end

    cmd
  end
end
