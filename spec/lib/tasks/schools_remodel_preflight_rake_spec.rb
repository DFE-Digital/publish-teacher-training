# frozen_string_literal: true

require "rails_helper"
require "rake"

describe "schools_remodel_preflight:run" do
  Rails.application.load_tasks if Rake::Task.tasks.empty?

  subject(:run_task) { Rake::Task["schools_remodel_preflight:run"].invoke("2026") }

  before { Rake::Task["schools_remodel_preflight:run"].reenable }

  let(:cycle) { create(:recruitment_cycle, year: "2026") }
  let(:provider) { create(:provider, recruitment_cycle: cycle) }
  let(:gias_school) { create(:gias_school) }

  context "when the data is clean" do
    before do
      uuid = SecureRandom.uuid
      create(:site, provider:, uuid:, code: "A", urn: gias_school.urn)
      create(:provider_school, provider:, gias_school:, site_code: "A", uuid:)
    end

    it "reports the counts without aborting" do
      expect { run_task }.to output(/orphan_provider_schools: 0/).to_stdout
    end
  end

  context "when an orphan provider_school exists" do
    before { create(:provider_school, provider:, gias_school:, site_code: "Z") }

    it "aborts so the task fails loudly in a deploy pipeline" do
      expect { run_task }.to raise_error(SystemExit).and(output(/BLOCKING/).to_stdout)
    end
  end
end
