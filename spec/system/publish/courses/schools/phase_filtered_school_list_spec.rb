# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish - Placement schools filtered by education phase", type: :system do
  before { given_i_am_authenticated_as_a_provider_user }

  scenario "a primary course lists only primary-phase schools" do
    given_a_course_at_level(:primary)
    when_i_visit_the_publish_course_school_edit_page

    then_i_see_the_schools("All Through School", "Nursery School", "Primary School")
    and_i_do_not_see_the_schools("Secondary School", "Sixteen Plus College")
  end

  scenario "a secondary course lists only secondary-phase schools" do
    given_a_course_at_level(:secondary)
    when_i_visit_the_publish_course_school_edit_page

    then_i_see_the_schools("All Through School", "Secondary School")
    and_i_do_not_see_the_schools("Nursery School", "Primary School", "Sixteen Plus College")
  end

  scenario "a further education course lists only sixteen plus schools" do
    given_a_course_at_level(:further_education)
    when_i_visit_the_publish_course_school_edit_page

    then_i_see_the_schools("Sixteen Plus College")
    and_i_do_not_see_the_schools("All Through School", "Primary School", "Secondary School")
  end

  # Rolled over courses keep schools the filter would now hide. Detaching them
  # is a separate ticket, so they have to stay visible and ticked — otherwise
  # the next save would silently detach them.
  scenario "an out-of-phase school already attached stays listed and ticked" do
    given_a_course_at_level(:secondary)
    and_the_course_is_attached_to("Primary School")
    when_i_visit_the_publish_course_school_edit_page

    then_i_see_the_schools("All Through School", "Primary School", "Secondary School")
    and_the_school_is_ticked("Primary School")
  end

  scenario "saving a course with an out-of-phase school attached keeps it attached" do
    given_a_course_at_level(:secondary)
    and_the_course_is_attached_to("Primary School")
    when_i_visit_the_publish_course_school_edit_page

    and_i_also_tick("Secondary School")
    and_i_submit

    then_the_course_is_attached_to("Primary School", "Secondary School")
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider)
    @user = create(:user, providers: [@provider])

    {
      "Nursery School" => :nursery,
      "Primary School" => :primary,
      "All Through School" => :all_through,
      "Secondary School" => :secondary,
      "Sixteen Plus College" => :sixteen_plus,
    }.each_with_index do |(name, phase_code), index|
      create_paired_school(provider: @provider, name:, site_code: "S#{index}")
        .last
        .gias_school
        .update!(phase_code:)
    end

    given_i_am_authenticated(user: @user)
  end

  def given_a_course_at_level(level)
    @course = create(:course, level, provider: @provider, sites: [])
  end

  def and_the_course_is_attached_to(name)
    provider_school = school_named(name)
    create(:site_status, :running, course: @course, site: provider_school.legacy_site)
    create(:course_school, course: @course, gias_school: provider_school.gias_school, provider_school:)
  end

  def when_i_visit_the_publish_course_school_edit_page
    publish_course_school_edit_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      course_code: @course.course_code,
    )
  end

  def then_i_see_the_schools(*names)
    expect(publish_course_school_edit_page.vacancy_names).to match_array(names)
  end

  def and_i_do_not_see_the_schools(*names)
    names.each { |name| expect(publish_course_school_edit_page.vacancy_names).not_to include(name) }
  end

  def and_the_school_is_ticked(name)
    expect(page.find(:checkbox, name, visible: :all)).to be_checked
  end

  def and_i_also_tick(name)
    check name
  end

  def and_i_submit
    publish_course_school_edit_page.submit.click
  end

  def then_the_course_is_attached_to(*names)
    attached = @course.reload.schools.map { |course_school| course_school.gias_school.name }

    expect(attached).to match_array(names)
  end

  def school_named(name)
    @provider.schools.joins(:gias_school).find_by!(gias_school: { name: })
  end
end
