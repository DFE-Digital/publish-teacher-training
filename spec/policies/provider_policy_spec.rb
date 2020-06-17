require "rails_helper"

describe ProviderPolicy do
  let(:user) { create(:user) }

  describe "scope" do
    let(:organisation) { create(:organisation, users: [user]) }

    it "limits the providers to those the user is assigned to" do
      provider1 = create(:provider, organisations: [organisation])
      _provider2 = create(:provider)

      expect(Pundit.policy_scope(user, Provider.all)).to eq [provider1]
    end
  end

  subject { described_class }

  permissions :index?, :suggest? do
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

  permissions :can_show_training_provider? do
    let(:admin) { build(:user, :admin) }
    let(:allowed_user) { provider.users.first }
    let(:not_allowed_user) { create(:user) }

    let(:provider) { course.accrediting_provider }
    let(:training_provider) { course.provider }
    let(:course) { create(:course, :with_accrediting_provider) }

    it { should permit(admin, training_provider) }
    it { should permit(allowed_user, training_provider) }
    it { should_not permit(not_allowed_user, training_provider) }
  end
end
