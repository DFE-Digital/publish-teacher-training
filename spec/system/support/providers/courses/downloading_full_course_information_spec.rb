# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Downloading full course information from support" do
  scenario "Support user downloads a provider's course description text" do
    given_i_am_authenticated_as_an_admin_user
    and_a_provider_has_a_course_with_description_text
    when_i_visit_the_support_provider_courses_page
    then_i_see_the_download_box
    when_i_download_the_full_course_information
    then_the_csv_carries_every_description_section
  end

  def provider
    @provider ||= create(:provider)
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def and_a_provider_has_a_course_with_description_text
    create(:course, :fee, provider:, name: "Chemistry", enrichments: [
      build(
        :course_enrichment,
        :published,
        placement_selection_criteria: "We match on travel time.",
        placement_school_activities: "You will teach a reduced timetable.",
        theoretical_training_activities: "Seminars on pedagogy.",
        interview_process: "A subject knowledge task and an interview.",
      ),
    ])
  end

  def when_i_visit_the_support_provider_courses_page
    visit support_recruitment_cycle_provider_courses_path(provider.recruitment_cycle_year, provider)
  end

  def then_i_see_the_download_box
    expect(page).to have_content("Download course information")
    expect(page).to have_link("Download basic course information (CSV)")
    expect(page).to have_link("Download the schools attached to each course (CSV)")
    expect(page).to have_link("Download full course information (CSV)")
  end

  def when_i_download_the_full_course_information
    click_link_or_button("Download full course information (CSV)")
  end

  def then_the_csv_carries_every_description_section
    row = CSV.parse(page.body.delete_prefix(Exports::CourseColumns::BYTE_ORDER_MARK), headers: true).first

    expect(row.to_h).to include(
      "Course name" => "Chemistry",
      "How do you decide which schools to place trainees in?" => "We match on travel time.",
      "What will trainees do while in their placement schools?" => "You will teach a reduced timetable.",
      "What will trainees do during their theoretical training?" => "Seminars on pedagogy.",
      "What is the interview process? (optional)" => "A subject knowledge task and an interview.",
    )
  end
end
