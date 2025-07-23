require "rails_helper"

RSpec.describe DiscardInvalidSchools::SummaryBuilder do
  subject(:builder) { described_class.new(no_urn_ids:, invalid_urns:) }

  let(:no_urn_ids) { [1, 2] }
  let(:invalid_urns) { [{ id: 3, urn: "A" }, { id: 4, urn: "B" }] }

  describe "#short_summary" do
    it "returns the correct counts" do
      expect(builder.short_summary).to eq(
        discarded_total_count: 4,
        discarded_lack_urn: 2,
        discarded_invalid_gias_urn: 2,
      )
    end
  end

  describe "#full_summary" do
    it "returns full details" do
      expect(builder.full_summary).to eq(
        discarded_ids_lack_urn: [1, 2],
        discarded_invalid_urns: [{ id: 3, urn: "A" }, { id: 4, urn: "B" }],
      )
    end
  end
end
