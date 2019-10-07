require "mcb_helper"

describe "mcb providers withdraw_courses" do
  def execute_withdraw_courses(arguments: [])
    $mcb.run(["providers", "withdraw_courses", *arguments])
  end

  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:provider) { create(:provider, courses: [course, course2], sites: [site], recruitment_cycle: current_cycle) }
  let(:course) { build(:course, site_statuses: [site_status]) }
  let(:course2) { build(:course, site_statuses: [site_status2]) }
  let(:site) { build(:site) }
  let(:site_status) { build(:site_status, :published, :full_time_vacancies, site: site) }
  let(:site_status2) { build(:site_status, :published, :full_time_vacancies, site: site) }

  let(:provider2) { create(:provider, courses: [course3, course4], sites: [site2], recruitment_cycle: current_cycle) }
  let(:course3)  { build(:course, site_statuses: [site_status3]) }
  let(:course4)  { build(:course, site_statuses: [site_status4]) }
  let(:site2) { build(:site) }
  let(:site_status3) { build(:site_status, :published, :full_time_vacancies, site: site2) }
  let(:site_status4) { build(:site_status, :published, :full_time_vacancies, site: site2) }


  it "withdraws the providers courses for the current cycle" do
    provider
    provider2
    execute_withdraw_courses(arguments: [provider.provider_code, provider2.provider_code])

    expect(course.reload.findable?).to eq false
    expect(course2.reload.findable?).to eq false
    expect(course3.reload.findable?).to eq false
    expect(course4.reload.findable?).to eq false
  end
end
