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

  subject { described_class }

  permissions :show? do
    let(:user) { create(:user) }
    let(:user_outside_org) { create(:user) }
    let(:provider) { create(:provider) }
    let!(:organisation) { create(:organisation, providers: [provider], users: [user]) }

    it { should permit(user, provider) }
    it { should_not permit(user_outside_org, provider) }
  end

  permissions :index? do
    let(:user) { create(:user) }

    it { should permit user }
  end
end
