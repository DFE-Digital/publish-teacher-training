require "rails_helper"

describe Sites::CopyToCourseService do
  let(:site) { create(:site) }
  let(:course) { create(:course, provider: new_provider) }
  let(:service) { described_class.new }
  let(:new_provider) {
    create :provider,
           recruitment_cycle: new_recruitment_cycle
  }
  let(:new_recruitment_cycle) { create :recruitment_cycle, :next }

  before do
    service.execute(new_site: site, new_course: course)
  end

  it "copies the site" do
    expect(course.sites.count).to eq(1)
  end

  it "has the same code as the original site" do
    new_site = course.sites.last
    expect(new_site.code).to eq(site.code)
  end

  describe "the new site's status" do
    subject { course.site_statuses.first }

    it { should be_full_time_vacancies }
    it { should be_status_new_status }
  end
end
