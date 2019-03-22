module MCB
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
