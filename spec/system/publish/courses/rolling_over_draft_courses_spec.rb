# frozen_string_literal: true

require "rails_helper"

# Rolling a course over runs the whole provider pipeline, sites included, so a
# provider with several draft courses gets rolled over once per course. The
# reported bug was a provider whose study sites appeared three times in the new
# cycle after its three courses were rolled over one at a time.
#
# Nothing here turns on which moment of the cycle it is, only on there being a
# cycle to roll over into. The year is pinned rather than left to the real date
# because Find::CycleTimetable::CYCLE_DATES is a hardcoded hash that ends at
# 2027, so an unpinned cycle eventually asks it for a year it does not hold.
RSpec.describe "Rolling over draft courses one at a time", travel: mid_cycle(2025) do
  scenario "the provider's sites are not duplicated" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_rollable_next_recruitment_cycle
    when_i_roll_over(@courses.first)
    and_i_roll_over(@courses.second)
    then_each_study_site_is_listed_once
    and_each_school_site_is_listed_once
  end

  def given_i_am_authenticated_as_a_provider_user
    @courses = build_list(:course, 2, enrichments: [build(:course_enrichment)], funding_type: "salary")
    @provider = create(
      :provider,
      sites: build_list(:site, 2, :with_gias_school, :with_provider_school),
      study_sites: build_list(:site, 2, :study_site),
      courses: @courses,
    )
    given_i_am_authenticated(user: create(:user, providers: [@provider]))
  end

  def and_there_is_a_rollable_next_recruitment_cycle
    find_or_create(:recruitment_cycle, :next)
    RecruitmentCycle.next.update(available_in_publish_from: 1.hour.ago)
  end

  def when_i_roll_over(course)
    rollover_form_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
    rollover_form_page.rollover_course_button.click

    expect(page).to have_content "Course rolled over"
  end

  alias_method :and_i_roll_over, :when_i_roll_over

  def then_each_study_site_is_listed_once
    visit "/publish/organisations/#{@provider.provider_code}/#{RecruitmentCycle.next.year}/study-sites"

    @provider.study_sites.each do |study_site|
      expect(page).to have_content(study_site.location_name, count: 1)
    end
    expect(next_cycle_provider.study_sites.count).to eq(2)
  end

  def and_each_school_site_is_listed_once
    expect(next_cycle_provider.sites.count).to eq(2)
  end

  def next_cycle_provider
    RecruitmentCycle.next.providers.find_by(provider_code: @provider.provider_code)
  end

  def rollover_form_page
    @rollover_form_page ||= PageObjects::Publish::DraftRollover.new
  end
end
