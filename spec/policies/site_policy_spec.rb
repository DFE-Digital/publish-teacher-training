require "rails_helper"

describe SitePolicy do
  let(:user) { create(:user) }

  subject { described_class }

  permissions :index? do
    it 'allows the :index action for any authenticated user' do
      should permit(user)
    end
  end

  permissions :show? do
    let(:organisation) { create(:organisation, users: [user]) }
    let(:site) { create(:site) }
    let!(:provider) {
      create(:provider,
             course_count: 0,
             sites: [site],
             organisations: [organisation])
    }

    it { should permit(user, site) }

    context 'with a user outside the organisation' do
      let(:other_user) { create(:user) }
      it { should_not permit(other_user, site) }
    end
  end
end
