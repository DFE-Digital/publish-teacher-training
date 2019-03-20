require "rails_helper"

describe 'Contact factory' do
  let(:contact) { create(:contact) }

  it 'creates ProviderUCASPreference object' do
    expect(contact).to be_instance_of(Contact)
    expect(contact).to be_valid
  end
end
