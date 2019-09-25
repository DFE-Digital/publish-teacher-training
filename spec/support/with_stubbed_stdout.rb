# Replace stdout with a StringIO for a given block of code, and return it.
#
# Utility function to help run 'mcb' commands in our specs, get the output and
# then test what was output. See examples in lib/mcb/commands tests. This
# approach is a slight modification of the 'capture' method that was available
# in Rails <=4. That implementation used a pipe and a separate thread to read
# from that pipe and write to a StringIO object. Unfortunately that
# implementation isn't threads-safe but this one should be.

def with_stubbed_stdout(stdin: nil, stderr: nil, &block)
  # if the parameters are wrong for a cli command then the error is written to
  # stderr which is lost when we have it mocked out. This env gives us a way to
  # disable redirection when trying to debug a failure in order to see the error
  # message.
  if ENV["WITHOUT_STUBBED_STDOUT"]
    yield
    { stdout: nil, stderr: nil }
  else
    stderr ||= ""
    stdout = run stdin: stdin, stderr: stderr, &block
    { stdout: stdout, stderr: stderr }
  end
end

private

def run(stdin: nil, stderr: nil)
  # Here is where we'll redirect STDOUT to temporarily. Using a StringIO
  # doesn't seem to work, it seems to require a proper file.
  output_file = Tempfile.new("stdout.")

  # We neeed to save a duplicate of the original STDOUT so that we can
  # re-instate it when we're done fiddling.
  original_stdout = STDOUT.dup

  # Here's where the magic happens. STDOUT is now redirecting to our tempfile.
  STDOUT.reopen(output_file)
  STDOUT.sync

  if stderr
    stderr_file = Tempfile.new("stderr.")
    original_stderr = STDERR.dup
    STDERR.reopen(stderr_file)
    STDERR.sync
  end

  # Maybe we should do stdin in a similar way, but for now this works so we'll
  # leave it. That may change if we ever decide to use ReadLine.
  if stdin
    original_stdin = $stdin
    $stdin = StringIO.new(stdin)
  end

  allow_any_instance_of(Binding).to receive(:pry)
                                      .and_raise("Cannot use pry with stubbed stdout")

  yield

  allow_any_instance_of(Binding).to receive(:pry).and_call_original

  # Restore STDOUT before we read back from the output file, which is why we
  # can't just rely on the ensure block to do it.
  STDOUT.reopen(original_stdout)

  if stderr
    STDERR.reopen(original_stderr)

    stderr_file.sync
    stderr_file.seek(0)
    stderr.replace stderr_file.read
  end

  output_file.sync
  output_file.seek(0)
  output_file.read
ensure
  # We need to restore STDOUT and remove the output file no matter what.
  STDOUT.reopen(original_stdout)
  STDOUT.sync
  output_file.unlink

  if stderr
    STDERR.reopen(original_stderr)
    STDERR.sync
    stderr_file.unlink
  end

  $stdin = original_stdin if stdin
end
