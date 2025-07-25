require "rails_helper"

RSpec.describe DataHub::DiscardInvalidSchools::SiteFilter do
  let(:recruitment_cycle) { create(:recruitment_cycle, year: "2025") }
  let(:provider) { create(:provider, recruitment_cycle:) }

  let!(:valid_site)           { create(:site, provider:, urn: "11111", location_name: "Valid School") }
  let!(:main_site_with_urn)   { create(:site, provider:, urn: nil, location_name: "Main Site") }
  let!(:non_gias_site)        { create(:site, provider:, urn: "99999", location_name: "Not in GIAS") }
  let!(:missing_urn_site)     { create(:site, provider:, urn: nil, location_name: "No URN School") }
  let!(:closed_gias_site)     { create(:site, provider:, urn: "22222", location_name: "Closed GIAS School") }
  let!(:empty_urn_site)       { create(:site, provider:, urn: "", location_name: "Empty URN School") }

  before do
    create(:gias_school, urn: "11111") # Valid (open)
    create(:gias_school, urn: "22222", status_code: "3") # Closed
  end

  it "returns only bad sites that are not 'Main Site'" do
    result = described_class.filter(recruitment_cycle:)

    expect(result).to contain_exactly(
      non_gias_site,
      missing_urn_site,
      closed_gias_site,
      empty_urn_site,
    )

    expect(result).not_to include(valid_site, main_site_with_urn)
  end
end
