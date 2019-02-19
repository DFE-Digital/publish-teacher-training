require "rails_helper"

describe ProviderPolicy do
  describe 'scope' do
    let(:user) { create(:user) }
    let(:organisation) { create(:organisation, users: [user]) }

    it 'limits the providers to those the user is assigned to' do
      provider1 = create(:provider, organisations: [organisation])
      _provider2 = create(:provider)

      expect(Pundit.policy_scope(user, Provider.all)).to eq [provider1]
    end
  end
end
