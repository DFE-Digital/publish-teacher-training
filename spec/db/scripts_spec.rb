require "rails_helper"

# These scripts are hand-written SQL run by the database-restore workflow
# (.github/workflows/database-restore.yml) against a restored production dump.
# They reference tables and columns by name, so a migration that renames or
# removes one silently rots them until the nightly restore fails. Running them
# against the current schema here turns that drift into a PR-time failure.
#
# Inserts run inside the per-example transaction and roll back automatically.
RSpec.describe "db/scripts" do
  def run_script(name)
    sql = Rails.root.join("db/scripts/#{name}.sql").read
    ActiveRecord::Base.connection.execute(sql)
  end

  it "sanitise.sql runs cleanly against the current schema" do
    expect { run_script("sanitise") }.not_to raise_error
  end

  it "integration_setup.sql runs cleanly against the current schema" do
    # The provider insert requires a recruitment cycle (recruitment_cycle_id is NOT NULL).
    create(:recruitment_cycle)

    expect { run_script("integration_setup") }.not_to raise_error
  end
end
