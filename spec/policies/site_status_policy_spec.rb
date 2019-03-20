require 'rails_helper'

describe SiteStatusPolicy do
  let(:organisation) { build :organisation, users: [user] }
  let(:provider)     { build :provider }
  let(:user)         { build :user }
  let(:site_status)  { course.site_statuses.first }
  let(:course) do
    build(
      :course,
      site_statuses: build_list(:site_status, 1),
      provider:      provider
    )
  end

  subject { described_class }

  permissions :update? do
    context 'with an user inside the organisation' do
      before do
        allow(user).to receive(:providers).and_return [provider]
      end
      it { should permit(user, site_status) }
    end

    context 'with a user outside the organisation' do
      let(:user) { build(:user) }

      it { should_not permit(user, site_status) }
    end
  end
end
