# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing placement schools on the basic details tab", travel: mid_cycle(2026) do
  before { given_i_am_authenticated_as_a_provider_user }

  scenario "with 6 or more schools the list collapses into a details component" do
    given_a_course_with_school_count(6)
    when_i_visit_the_course_basic_details_page
    then_the_schools_are_inside_a_details_component
    and_the_details_summary_shows_the_count(6)
  end

  scenario "with 5 or fewer schools the list is shown inline" do
    given_a_course_with_school_count(5)
    when_i_visit_the_course_basic_details_page
    then_the_schools_are_shown_inline_without_a_details_component
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, providers: [build(:provider)]))
  end

  def provider
    @provider ||= current_user.providers.first
  end

  def given_a_course_with_school_count(count)
    sites = Array.new(count) { |i| build(:site, provider:, location_name: sprintf("School %02d", i + 1)) }
    @course = create(:course, provider:, sites:)
    attach_course_schools_for_sites(sites, course: @course)
  end

  def when_i_visit_the_course_basic_details_page
    visit details_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      @course.course_code,
    )
  end

  def schools_row
    page.find('[data-qa="course__schools"]')
  end

  def then_the_schools_are_inside_a_details_component
    # The list is collapsed inside the details component, so its content is
    # hidden until the summary is toggled — assert against all elements.
    expect(schools_row).to have_css("details ul.govuk-list li", text: "School 01", visible: :all)
  end

  def and_the_details_summary_shows_the_count(count)
    expect(schools_row).to have_css("details summary", text: "#{count} schools attached")
  end

  def then_the_schools_are_shown_inline_without_a_details_component
    expect(schools_row).to have_no_css("details")
    expect(schools_row).to have_css("ul.govuk-list li", text: "School 01")
  end
end
