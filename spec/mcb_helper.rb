require "spec_helper"

load "bin/mcb"

def audit_user_tag(example)
  if example.metadata[:needs_audit_user]
    Audited.store[:audited_user] = requester
  end
end

def stub_init_rails_tag(example)
  unless example.metadata[:stub_init_rails] == false
    # "init_rails" will try to exec the Rails runner if Rails isn't already
    # loaded.
    allow(MCB).to receive(:init_rails)
  end
end

RSpec.configure do |config|
  # Ensure all mcb specs are tagged up so that the below hooks run to stub out
  # the dangerous things that we wouldn't want to leak through to the user's
  # system or dirty the test environment.
  config.define_derived_metadata(
    file_path: %r{spec/lib/mcb.* | bin/mcb_spec.rb}x,
  ) do |metadata|
    metadata[:mcb_cli] = true
  end


  # Certain methods can change stuff permanently in tests, causing intermittent
  # false positives or false negatives, or other issues. Any spec that tests
  # the mcb CLI should, to be safe, have the 'mcb_cli: true' metadata to ensure
  # it's safe.
  config.before(:each, mcb_cli: true) do |example|
    # This gets memoized so needs to be wiped out for every test.
    MCB.instance_eval { @config = nil }

    stub_init_rails_tag(example)
    audit_user_tag(example)

    # "run_command" is used to run "az" and maybe more. Any test relying on
    # this must stub for it specifically.
    allow(MCB).to receive(:run_command)
  end

  # Open3.pipeline_w is used to page stdout through less. For some reason Open3
  # is undefined in our tests, but even if it were we'd probably want to stub
  # it out.
  config.around(:each, mcb_cli: true) do |example|
    module ::Open3
      def self.pipeline_w(_cmds)
        yield STDOUT
      end
    end

    example.run

    Object.__send__(:remove_const, :Open3)
  end

  # Ensure that if the config file that is read is not the user's real data,
  # and if saved for any reason it does not over-write the user's.
  config.around(:each, mcb_cli: true) do |example|
    # Re-initialize $mcb and everything else. If we don't, then certain cmdline
    # options might persist between commands, e.g. when testing
    # lib/mcb/commands/apiv1/courses/find_spec.rb' and
    # lib/mcb/commands/apiv1/providers/find_spec.rb the 'endpoint' option used
    # by the two commands being tested gets set by the first test to the
    # default value defined in courses/find_spec.rb and then persists to the
    # providers/find_spec.rb
    load "bin/mcb"

    @temp_config_file = Tempfile.new ["mcb_cli_config", ".yml"]
    @temp_config_file.close
    MCB.config_file = @temp_config_file.path
    example.run
    @temp_config_file.unlink
  end
end
