require "rails_helper"

describe SiteStatusSerializer do
  subject { serialize(site_status) }

  context "when the site status has some vacancies" do
    let(:site_status) { create :site_status, :full_time_vacancies }
    its([:status]) { should eq(site_status.status_before_type_cast) }
  end

  context "when the site status has no vacancies" do
    let(:site_status) { create :site_status, :with_no_vacancies }
    its([:status]) { should eq(SiteStatus.statuses["suspended"]) }
  end
end
