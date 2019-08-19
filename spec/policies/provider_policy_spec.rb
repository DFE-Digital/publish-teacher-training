require "rails_helper"

describe ProviderPolicy do
  let(:user) { create(:user) }

  describe 'scope' do
    let(:organisation) { create(:organisation, users: [user]) }

    it 'limits the providers to those the user is assigned to' do
      provider1 = create(:provider, organisations: [organisation])
      _provider2 = create(:provider)

      expect(Pundit.policy_scope(user, Provider.all)).to eq [provider1]
    end
  end

  subject { described_class }

  permissions :show?, :update?, :sync_courses_with_search_and_compare?, :can_list_courses? do
    let(:user) { create(:user) }
    let(:user_outside_org) { create(:user) }
    let(:provider) { create(:provider) }
    let!(:organisation) { create(:organisation, providers: [provider], users: [user]) }

    it { should permit(user, provider) }
    it { should_not permit(user_outside_org, provider) }
  end

  permissions :index? do
    it { should permit user }
  end

  permissions :create? do
    let(:user_outside_org) { create(:user) }
    let(:admin) { create(:user, :admin) }
    let(:provider) { create(:provider) }
    let!(:organisation) { create(:organisation, providers: [provider], users: [user]) }

    it { should_not permit(user, provider) }
    it { should_not permit(user_outside_org, provider) }
    it { should permit(admin, provider) }
  end
end
