# Replace stdout with a StringIO for a given block of code, and return it.
#
# Utility function to help run 'mcb' commands in our specs, get the output and
# then test what was output. See examples in lib/mcb/commands tests.
def with_stubbed_stdout(stdin: nil)
  output = StringIO.new
  original_stdout = $stdout
  $stdout = output
  MCB::LOGGER.instance_eval { @logdev = output } if defined? MCB
  unless stdin.nil?
    original_stdin = $stdin
    $stdin = StringIO.new(stdin)
  end

  yield

  output
ensure
  $stdout = original_stdout
  MCB::LOGGER.instance_eval { @logdev = original_stdout } if defined? MCB
  $stdin = original_stdin if stdin
end
