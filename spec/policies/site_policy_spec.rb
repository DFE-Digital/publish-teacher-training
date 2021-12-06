require "rails_helper"

describe SitePolicy do
  let(:user) { create(:user) }

  subject { described_class }

  permissions :index? do
    it "allows the :index action for any authenticated user" do
      expect(subject).to permit(user)
    end
  end

  permissions :show? do
    let(:site) { create(:site) }
    let!(:provider) {
      create(:provider,
             sites: [site],
             users: [user])
    }

    it { is_expected.to permit(user, site) }

    context "with a user outside the provider" do
      let(:other_user) { create(:user) }

      it { is_expected.to_not permit(other_user, site) }
    end
  end
end
