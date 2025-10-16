# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::SitesDeduplicationProcessSummary, type: :model do
  subject(:summary) do
    described_class.create!(
      started_at: Time.zone.now,
      finished_at: Time.zone.now,
      status: "finished",
      short_summary: {
        dry_run: false,
        duplicate_groups_processed: 2,
        duplicate_sites_discarded: 3,
        site_statuses_reassigned: 4,
        site_statuses_merged: 1,
        site_statuses_removed: 1,
      },
      full_summary: {
        deduplicated_groups: [
          {
            primary_site_id: 10,
            duplicate_site_ids: [11],
            sites_discarded: [11],
            site_status_reassignments: [{ site_status_id: 99, course_id: 100 }],
            site_status_merges: [],
            site_status_removals: [],
          },
        ],
      },
    )
  end

  it "provides typed accessors for the stored summary data" do
    expect(summary).to be_valid
    expect(summary.dry_run).to be(false)
    expect(summary.duplicate_groups_processed).to eq(2)
    expect(summary.duplicate_sites_discarded).to eq(3)
    expect(summary.site_statuses_reassigned).to eq(4)
    expect(summary.site_statuses_merged).to eq(1)
    expect(summary.site_statuses_removed).to eq(1)
    expect(summary.deduplicated_groups.first["primary_site_id"]).to eq(10)
  end
end
