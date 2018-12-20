require "rails_helper"

RSpec.describe ProviderSerializer do
  let(:provider) { create :provider }
  subject { serialize(provider) }

  it { is_expected.to include(institution_code: provider.provider_code, institution_name: provider.provider_name) }
end
