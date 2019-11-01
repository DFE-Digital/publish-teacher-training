# == Schema Information
#
# Table name: course_site
#
#  course_id  :integer
#  id         :integer          not null, primary key
#  publish    :text
#  site_id    :integer
#  status     :text
#  vac_status :text
#
# Indexes
#
#  IX_course_site_course_id  (course_id)
#  IX_course_site_site_id    (site_id)
#

require "rails_helper"

RSpec.describe SiteStatusSerializer do
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
