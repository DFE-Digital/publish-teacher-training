# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::DuplicateSchoolsProcessSummary, type: :model do
  subject(:summary) do
    described_class.create!(
      started_at: Time.zone.now,
      finished_at: Time.zone.now,
      status: "finished",
      short_summary: {
        years: %w[2026],
        groups_processed: 2,
        surplus_sites: 3,
        surplus_provider_schools: 1,
        kinds: [
          { kind: "main_site_collision", groups: 1, surplus_sites: 1, surplus_provider_schools: 1 },
          { kind: "clone", groups: 1, surplus_sites: 2, surplus_provider_schools: 0 },
        ],
        flags: [{ flag: "main_site_at_risk", groups: 1 }],
      },
      full_summary: {
        duplicate_groups: [
          {
            year: "2026",
            provider_code: "1TZ",
            urn: "144834",
            kind: "main_site_collision",
            flags: %w[main_site_at_risk],
            sites: [{ id: 10, code: "-", location_name: "Main Site" }],
            provider_schools: [{ id: 20, site_code: "-", course_schools: 2 }],
          },
        ],
      },
    )
  end

  it "provides typed accessors for the stored summary data" do
    expect(summary).to be_valid
    expect(summary.years).to eq(%w[2026])
    expect(summary.groups_processed).to eq(2)
    expect(summary.surplus_sites).to eq(3)
    expect(summary.surplus_provider_schools).to eq(1)
    expect(summary.kinds.first["kind"]).to eq("main_site_collision")
    expect(summary.flags.first).to eq({ "flag" => "main_site_at_risk", "groups" => 1 })
    expect(summary.duplicate_groups.first["sites"].first["code"]).to eq("-")
  end

  it "is a process summary" do
    expect(summary).to be_a(DataHub::ProcessSummary)
    expect(summary.type).to eq("DataHub::DuplicateSchoolsProcessSummary")
  end
end
