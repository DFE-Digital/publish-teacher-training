# frozen_string_literal: true

require "rails_helper"

# Rolling a provider over twice must not duplicate its schools or study sites. The per-course
# rollover in Publish (Publish::Courses::DraftRolloverController) runs the whole
# provider pipeline once per course, so a provider with three draft courses is
# rolled over three times in a row by design.
#
# Deliberately unmocked, unlike spec/services/rollover_provider_service_spec.rb —
# the collaborators have to write real rows for a repeat run to be observable.
RSpec.describe RolloverProviderService do
  subject(:new_provider) do
    next_recruitment_cycle.reload.providers.find_by(provider_code: provider.provider_code)
  end

  let!(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }
  let(:provider) { create(:provider) }
  let!(:school_sites) { create_list(:site, 2, :with_gias_school, :with_provider_school, provider:) }
  let!(:study_sites) { create_list(:site, 2, :study_site, provider:) }
  let!(:courses) { create_list(:course, 3, provider:) }

  def roll_over(course)
    described_class.call(provider_code: provider.provider_code, course_codes: [course.course_code], force: true)
  end

  it "copies the schools and study sites once when a single course is rolled over" do
    roll_over(courses.first)

    expect(new_provider.schools.count).to eq(2)
    expect(new_provider.study_sites.count).to eq(2)
  end

  it "does not copy the legacy school sites" do
    roll_over(courses.first)

    expect(new_provider.sites.school).to be_empty
  end

  context "when a provider school has no legacy site" do
    let!(:school_without_site) { create(:provider_school, provider:) }

    it "rolls it over" do
      roll_over(courses.first)

      expect(new_provider.schools.pluck(:gias_school_id)).to include(school_without_site.gias_school_id)
    end
  end

  context "when each course is rolled over separately" do
    before { courses.each { roll_over(it) } }

    it "does not duplicate the study sites" do
      expect(new_provider.study_sites.count).to eq(2)
      expect(new_provider.study_sites.pluck(:location_name)).to match_array(study_sites.map(&:location_name))
    end

    it "gives each copied study site its own code" do
      expect(new_provider.study_sites.pluck(:code).uniq.size).to eq(2)
    end

    it "does not duplicate the provider schools" do
      expect(new_provider.schools.count).to eq(2)
    end

    it "copies every course" do
      expect(new_provider.courses.pluck(:course_code)).to match_array(courses.map(&:course_code))
    end
  end

  # The guard this fix replaces matched on code alone and read school and study
  # site codes as one namespace, so a study site sharing a school site's code was
  # dropped and never rolled over at all. Removing that guard is what let repeat
  # runs duplicate. Both halves have to hold at once.
  context "when a study site shares a school site's code" do
    let!(:study_sites) do
      [
        create(:site, :study_site, provider:, code: school_sites.first.code),
        create(:site, :study_site, provider:),
      ]
    end

    it "copies it exactly once across repeated rollovers" do
      courses.each { roll_over(it) }

      expect(new_provider.study_sites.count).to eq(2)
      expect(new_provider.study_sites.pluck(:location_name)).to match_array(study_sites.map(&:location_name))
    end
  end

  it "reports the sites it left alone rather than counting them as copied" do
    roll_over(courses.first)

    result = roll_over(courses.second)

    expect(result).to include(
      sites: 0,
      sites_already_present: 2,
      sites_skipped: [],
      study_sites: 0,
      study_sites_already_present: 2,
      study_sites_skipped: [],
    )
  end
end
