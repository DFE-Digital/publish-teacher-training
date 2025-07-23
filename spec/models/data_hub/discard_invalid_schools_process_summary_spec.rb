require "rails_helper"

RSpec.describe DataHub::DiscardInvalidSchoolsProcessSummary, type: :model do
  subject(:summary) do
    described_class.create!(
      started_at: Time.zone.now,
      finished_at: Time.zone.now,
      status: "finished",
      short_summary: {
        discarded_total_count: 5,
        discarded_lack_urn: 2,
        discarded_invalid_gias_urn: 3,
      },
      full_summary: {
        discarded_ids_lack_urn: [1, 2],
        discarded_invalid_urns: [{ id: 3, urn: "123" }],
      },
    )
  end

  it "validates presence and formats" do
    expect(summary).to be_valid
    expect(summary.discarded_total_count).to eq(5)
    expect(summary.discarded_lack_urn).to eq(2)
    expect(summary.discarded_invalid_gias_urn).to eq(3)
    expect(summary.discarded_ids_lack_urn).to eq([1, 2])
    expect(summary.discarded_invalid_urns).to eq([{ "id" => 3, "urn" => "123" }])
  end
end
