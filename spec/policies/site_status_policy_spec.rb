require "rails_helper"

describe SiteStatusPolicy do
  let(:organisation) { site_status.course.provider.organisations.first }
  let(:site_status) { create :site_status }

  subject { described_class }

  permissions :update? do
    let(:user) { create(:user).tap { |u| organisation.users << u } }

    context "with an user inside the organisation" do
      it { should permit(user, site_status) }
    end

    context "with a user outside the organisation" do
      let(:user) { build(:user) }

      it { should_not permit(user, site_status) }
    end
  end
end
