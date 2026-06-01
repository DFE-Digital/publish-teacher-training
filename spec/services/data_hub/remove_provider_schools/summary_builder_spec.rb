require "rails_helper"

RSpec.describe DataHub::RemoveProviderSchools::SummaryBuilder do
  subject(:builder) do
    described_class.new(
      removed: [{ id: 1, urn: "99999", location_name: "Remove School" }],
      skipped_with_courses: [{ id: 2, urn: "88888", location_name: "Has Course" }],
      kept_present: %w[11111],
      kept_missing: %w[22222],
    )
  end

  it "builds the short summary with counts" do
    expect(builder.short_summary).to eq(
      removed_count: 1,
      skipped_with_courses_count: 1,
      kept_present_count: 1,
      kept_missing_count: 1,
    )
  end

  it "builds the full summary with details" do
    expect(builder.full_summary).to eq(
      removed: [{ id: 1, urn: "99999", location_name: "Remove School" }],
      skipped_with_courses: [{ id: 2, urn: "88888", location_name: "Has Course" }],
      kept_present: %w[11111],
      kept_missing: %w[22222],
    )
  end
end
