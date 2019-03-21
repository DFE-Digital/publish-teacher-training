require 'rails_helper'

describe SiteStatusPolicy do
  let(:organisation) { create(:organisation, users: [user]) }
  let!(:provider) {
    create(:provider,
            course_count: 0,
            courses: [course],
            organisations: [organisation])
  }
  let!(:course) do
    create(
      :course,
      site_statuses: build_list(:site_status, 1)
    )
  end
  let(:site_status) { course.site_statuses.first }

  subject { described_class }

  permissions :update? do
    let(:user) { create :user }

    context 'with an user inside the organisation' do
      it { should permit(user, site_status) }
    end

    context 'with a user outside the organisation' do
      let(:user_outside_provider) { build(:user) }

      it { should_not permit(user_outside_provider, site_status) }
    end
  end
end
