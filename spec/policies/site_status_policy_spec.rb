require "rails_helper"

describe SiteStatusPolicy do
  let(:provider) { site_status.course.provider }
  let(:site_status) { create :site_status }

  subject { described_class }

  permissions :update? do
    let(:user) { create(:user).tap { |u| provider.users << u } }

    context "with an user inside the provider" do
      it { is_expected.to permit(user, site_status) }
    end

    context "with a user outside the provider" do
      let(:user) { build(:user) }

      it { is_expected.not_to permit(user, site_status) }
    end
  end
end
