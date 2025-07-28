require "rails_helper"

RSpec.describe DataHub::UpdateSitesFromGias::SummaryBuilder do
  subject(:builder) { described_class.new(results) }

  let(:results) do
    [
      double(
        site_id: 1,
        changes: {
          address2: { before: "X", after: "Y" },
          address3: { before: "A", after: "B" },
        },
      ),
      double(
        site_id: 2,
        changes: {
          location_name: { before: "A", after: "B" },
          latitude: { before: 1, after: 2 },
        },
      ),
      double(
        site_id: 3,
        changes: {
          postcode: { before: "P1", after: "P2" },
          longitude: { before: 10.1, after: 10.2 },
          town: { before: "Old", after: "New" },
        },
      ),
      double(
        site_id: 4,
        changes: {},
      ),
    ]
  end

  it "builds the short summary with accurate field counts" do
    summary = builder.short_summary
    expect(summary[:updated_total_count]).to eq(3)
    expect(summary[:address2]).to eq(1)
    expect(summary[:address3]).to eq(1)
    expect(summary[:location_name]).to eq(1)
    expect(summary[:latitude]).to eq(1)
    expect(summary[:postcode]).to eq(1)
    expect(summary[:longitude]).to eq(1)
    expect(summary[:town]).to eq(1)
    expect(summary[:address1]).to eq(0)
  end

  it "includes every expected field in the short summary" do
    fields = %i[
      location_name address1 address2 address3 town address4 postcode latitude longitude
    ]
    fields.each { |field| expect(builder.short_summary).to have_key(field) }
  end

  it "only includes updated sites in full summary" do
    site_ids = builder.full_summary[:site_updates].map { |hash| hash[:id] }
    expect(site_ids).to contain_exactly(1, 2, 3)
    expect(site_ids).not_to include(4)
  end
end
