require "mcb_helper"

describe "mcb providers touch" do
  def execute_withdraw_courses
    $mcb.run(["providers", "withdraw_courses"])
  end
  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:provider) { create(:provider, provider_code: '1XN', courses: [course, course2], sites: [site], recruitment_cycle: current_cycle) }
  let(:course)  { build(:course, site_statuses: [site_status]) }
  let(:course2)  { build(:course, site_statuses: [site_status2]) }
  let(:site) { build(:site) }
  let(:site_status) { build(:site_status, :published, :full_time_vacancies, site: site) }
  let(:site_status2) { build(:site_status, :published, :full_time_vacancies, site: site) }

  let(:provider2) { create(:provider, provider_code: '1KM', courses: [course3, course4], sites: [site2], recruitment_cycle: current_cycle) }
  let(:course3)  { build(:course, site_statuses: [site_status3]) }
  let(:course4)  { build(:course, site_statuses: [site_status4]) }
  let(:site2) { build(:site) }
  let(:site_status3) { build(:site_status, :published, :full_time_vacancies, site: site2) }
  let(:site_status4) { build(:site_status, :published, :full_time_vacancies, site: site2) }


  it "makes the providers coursesfor the current cycle non-findable" do
    provider
    provider2

    execute_withdraw_courses

    expect(course.reload.findable?).to eq false
    expect(course2.reload.findable?).to eq false
    expect(course3.reload.findable?).to eq false
    expect(course4.reload.findable?).to eq false
  end
end
