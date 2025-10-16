# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Sites::Deduplication::Executor do
  it "records the deduplication outcome in a process summary" do
    provider = create(:provider)
    primary = create(:site, provider:, location_name: "Example School", postcode: "SW1A 1AA", urn: "12345")
    duplicate = create(:site, provider:, location_name: "Example School", postcode: "SW1A 1AA", urn: "12345")

    create(:site_status, site: primary, course: create(:course, provider:), status: "running", publish: "N", vac_status: "F")

    course = create(:course, provider:)
    create(:site_status, site: duplicate, course:, status: "running", publish: "Y", vac_status: "F")

    executor = described_class.new(site_scope: Site.where(id: [primary.id, duplicate.id]), dry_run: false)

    expect { executor.execute }.to change(DataHub::SitesDeduplicationProcessSummary, :count).by(1)

    process_summary = DataHub::SitesDeduplicationProcessSummary.order(:created_at).last

    expect(process_summary.status).to eq("finished")
    expect(process_summary.duplicate_groups_processed).to eq(1)
    expect(process_summary.duplicate_sites_discarded).to eq(1)
    expect(process_summary.site_statuses_reassigned).to eq(1)
    expect(process_summary.dry_run).to be(false)
  end

  it "marks the process summary as failed when an error occurs" do
    failing_scope = double(:scope)
    executor = described_class.new(site_scope: failing_scope, dry_run: false)

    allow(DataHub::SitesDeduplicationProcessSummary).to receive(:start!).and_call_original
    allow(failing_scope).to receive(:kept).and_raise(StandardError.new("boom"))

    expect { executor.execute }.to raise_error(StandardError, "boom")

    expect(DataHub::SitesDeduplicationProcessSummary.last.status).to eq("failed")
    expect(DataHub::SitesDeduplicationProcessSummary.last.short_summary["error_message"]).to eq("boom")
  end
end
