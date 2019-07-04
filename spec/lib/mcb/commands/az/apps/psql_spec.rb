require 'spec_helper'
require 'mcb_helper'

describe 'mcb az apps psql' do
  it 'returns the psql of apps' do
    allow(MCB).to receive(:exec_command).with(
      "psql",
      "-h", "localhost",
      "-U", "manage_courses_backend",
      "-d", "manage_courses_backend_development"
    )

    with_stubbed_stdout do
      $mcb.run(%w[az apps psql])
    end
  end
end
