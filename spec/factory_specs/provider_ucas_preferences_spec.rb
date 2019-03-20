require "rails_helper"

describe 'ProviderUCASPreference factory' do
  let(:provider_ucas_preferences) { create(:provider_ucas_preference) }

  it 'creates ProviderUCASPreference object' do
    expect(provider_ucas_preferences).to be_instance_of(ProviderUCASPreference)
    expect(provider_ucas_preferences).to be_valid
  end
end
