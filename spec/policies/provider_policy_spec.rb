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

  subject { ProviderPolicy.new(user, provider) }

  describe 'show?' do
    let(:user) { create(:user) }
    let(:user_outside_org) { create(:user) }
    let(:provider) { create(:provider) }
    let!(:organisation) { create(:organisation, providers: [provider], users: [user]) }

    it 'permits showing providers that the user can manage' do
      expect(ProviderPolicy.new(user, provider).show?).to be_truthy
    end

    it "doesn't permit showing providers outside the user's orgs" do
      expect(ProviderPolicy.new(user_outside_org, provider).show?).to be_falsey
    end
  end
end
