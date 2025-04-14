# frozen_string_literal: true

require "rails_helper"

feature "Viewing an undergraduate course" do
  include Rails.application.routes.url_helpers

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  after do
    Timecop.return
  end

  scenario "user visits get into teaching advice page" do
    given_there_is_a_findable_undergraduate_course
    when_i_visit_the_course_page
    then_i_see_the_tda_advice_callout
    and_i_do_not_see_the_support_and_advice_callout
    when_i_click_to_contact_get_into_teaching
    then_i_am_redirected_to_the_git_help_and_support_page
  end

  def given_there_is_a_findable_undergraduate_course
    user = create(:user, providers: [build(:provider, provider_type: "lead_school", sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])])
    provider = user.providers.first
    create(:provider, :accredited_provider, provider_code: "1BK")
    @course = create(:course, :published_teacher_degree_apprenticeship, :secondary, provider:, name: "Biology", subjects: [find_or_create(:secondary_subject, :biology)])
  end

  def when_i_visit_the_course_page
    visit find_course_path(
      provider_code: @course.provider.provider_code,
      course_code: @course.course_code,
    )
  end

  def then_i_see_the_tda_advice_callout
    expect(page).to have_css("h2", text: "Teacher degree apprenticeship")
    expect(page).to have_content("On a teacher degree apprenticeship you’ll work in a school and earn a salary while getting a bachelor’s degree and qualified teacher status (QTS).")
  end

  def and_i_do_not_see_the_support_and_advice_callout
    expect(page).to have_no_css("h2", text: "Support and advice")
  end

  def when_i_click_to_contact_get_into_teaching
    click_link_or_button("Find out more about teacher degree apprenticeships.")
  end

  def then_i_am_redirected_to_the_git_help_and_support_page
    expect(page.current_url).to eq(
      "https://getintoteaching.education.gov.uk/train-to-be-a-teacher/teacher-degree-apprenticeships",
    )
  end
end
