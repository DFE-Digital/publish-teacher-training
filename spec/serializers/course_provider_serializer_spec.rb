require "rails_helper"

RSpec.describe CourseProviderSerializer do
  let(:provider) { create :provider }

  subject { serialize(provider, serializer_class: described_class) }

  it { is_expected.to include(accrediting_provider: provider.accrediting_provider_before_type_cast) }

  describe "campuses" do
    before do
      create_list(:site, 40, code: nil, provider: provider)
    end

    subject { serialize(provider, serializer_class: described_class)["campuses"] }

    its(:count) { is_expected.to eq(37) }
  end
end
