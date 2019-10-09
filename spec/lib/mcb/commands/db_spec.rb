require "spec_helper"
require "mcb_helper"

describe "mcb db" do
  it "runs psql for localhost" do
    allow(MCB).to receive(:exec_command).with(
      "psql",
      "-h", "localhost",
      "-U", "manage_courses_backend",
      "-d", "manage_courses_backend_development"
    )

    with_stubbed_stdout do
      $mcb.run(%w[db])
    end
  end

  context "with qa environment specified" do
    before do
      app_config = {
        "MANAGE_COURSES_POSTGRESQL_SERVICE_HOST" => "azhost",
        "PG_DATABASE"                            => "pgdb",
        "PG_USERNAME"                            => "azuser",
        "PG_PASSWORD"                            => "azpass",
        "RAILS_ENV"                              => "qa",
      }
      allow(MCB::Azure).to(receive(:get_config).and_return(app_config))
    end

    it "runs psql for azure server" do
      allow(MCB).to receive(:exec_command).with(
        "psql",
        "-h", "azhost",
        "-U", "azuser",
        "-d", "pgdb"
      )

      with_stubbed_stdout(stdin: "qa") do
        $mcb.run(%w[db -E qa])
      end
    end

    it "runs psql for azure backup host" do
      allow(MCB).to receive(:exec_command).with(
        "psql",
        "-h", "backup-host.postgres.database.azure.com",
        "-U", "azuser",
        "-d", "pgdb"
      )

      with_stubbed_stdout(stdin: "qa") do
        $mcb.run(%w[db -E qa -H backup-host])
      end
    end
  end
end
