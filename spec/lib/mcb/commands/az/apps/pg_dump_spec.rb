require 'spec_helper'
require 'mcb_helper'

describe 'mcb az apps pg_dump' do
  it 'returns the pg_dump of apps' do
    allow(MCB).to receive(:exec_command)
                    .with("pg_dump --encoding utf8 --clean --if-exists -h localhost -U manage_courses_backend -d manage_courses_backend_development --file 'localhost_manage_courses_backend_development.sql'")

    with_stubbed_stdout do
      $mcb.run(%w[az apps pg_dump])
    end
  end
end
