require "rails_helper"

RSpec.describe DataHub::RemoveProviderSchoolsProcessSummary, type: :model do
  subject(:summary) do
    described_class.create!(
      started_at: Time.zone.now,
      finished_at: Time.zone.now,
      status: "finished",
      short_summary: {
        removed_count: 2,
        skipped_with_courses_count: 1,
        kept_present_count: 1,
        kept_missing_count: 1,
      },
      full_summary: {
        removed: [{ id: 1, urn: "99999", location_name: "Remove School" }],
        skipped_with_courses: [{ id: 2, urn: "88888", location_name: "Has Course" }],
        kept_present: %w[11111],
        kept_missing: %w[22222],
      },
    )
  end

  it "validates presence and formats" do
    expect(summary).to be_valid
    expect(summary.removed_count).to eq(2)
    expect(summary.skipped_with_courses_count).to eq(1)
    expect(summary.kept_present_count).to eq(1)
    expect(summary.kept_missing_count).to eq(1)
    expect(summary.removed).to eq([{ "id" => 1, "urn" => "99999", "location_name" => "Remove School" }])
    expect(summary.kept_present).to eq(%w[11111])
    expect(summary.kept_missing).to eq(%w[22222])
  end
end
