class MCBCommand
  def initialize(*command)
    @command = command
  end

  def execute(arguments: [], input: [])
    stderr = nil
    output = with_stubbed_stdout(stdin: input.join("\n"), stderr: stderr) do
      $mcb.run(@command + arguments)
    end
    { stdout: output, stderr: stderr }
  end
end
