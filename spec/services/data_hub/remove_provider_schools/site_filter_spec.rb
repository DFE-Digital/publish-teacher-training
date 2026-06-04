require "rails_helper"

RSpec.describe DataHub::RemoveProviderSchools::SiteFilter do
  let(:recruitment_cycle) { create(:recruitment_cycle, year: "2025") }
  let(:provider) { create(:provider, recruitment_cycle:) }
  let(:keep_urns) { %w[11111 22222] }

  let!(:keep_site_a)  { create(:site, provider:, urn: "11111", location_name: "Keep School A") }
  let!(:keep_site_b)  { create(:site, provider:, urn: "22222", location_name: "Keep School B") }
  let!(:remove_site)  { create(:site, provider:, urn: "99999", location_name: "Remove School") }
  let!(:main_site)    { create(:site, :main_site, provider:, location_name: "Main Site") }

  it "returns school sites to remove, excluding kept URNs and the main site" do
    result = described_class.filter(provider:, keep_urns:)

    expect(result).to contain_exactly(remove_site)
    expect(result).not_to include(keep_site_a, keep_site_b, main_site)
  end

  it "does not return another provider's schools" do
    other_provider = create(:provider, recruitment_cycle:)
    create(:site, provider: other_provider, urn: "88888", location_name: "Other Provider School")

    result = described_class.filter(provider:, keep_urns:)

    expect(result).to contain_exactly(remove_site)
  end

  it "does not return study sites" do
    create(:site, :study_site, provider:, location_name: "Study Site")

    result = described_class.filter(provider:, keep_urns:)

    expect(result).to contain_exactly(remove_site)
  end
end
