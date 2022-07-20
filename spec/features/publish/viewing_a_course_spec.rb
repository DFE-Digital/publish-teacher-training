# frozen_string_literal: true

require "rails_helper"

feature "Course show", { can_edit_current_and_next_cycles: false } do
  include ActiveSupport::NumberHelper

  scenario "i can view the course basic details" do
    given_i_am_authenticated_as_a_provider_user(course: build(:course))
    when_i_visit_the_course_page
    and_i_click_on_basic_details
    then_i_see_the_course_basic_details
  end

  describe "with a fee paying course" do
    scenario "i can view a fee course" do
      given_i_am_authenticated_as_a_provider_user(course: course_with_financial_incentive)
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_fee_course
      and_i_should_see_the_course_button_panel
    end
  end

  describe "with a salary paying course" do
    scenario "i can view a salary course" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment], funding_type: "salary"))
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_salary_course
      and_i_should_see_the_course_button_panel
    end
  end

  describe "with a published and running course" do
    scenario "i can view the published partial" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment], funding_type: "salary", site_statuses: [build(:site_status, :findable)]))
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_salary_course
      and_i_should_see_the_course_button_panel
      # and_i_should_see_the_published_partial
      # and_i_should_not_see_the_rollover_button
    end
  end

  describe "with a published with unpublished changes course" do
    scenario "i can view the unpublished partial" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment_unpublished_changes], funding_type: "salary"))
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_unpublished_changes_course
      and_i_should_see_the_course_button_panel
      # and_i_should_see_the_unpublished_with_changes_partial
      # and_i_should_not_see_the_rollover_button
    end
  end

  describe "with an initial draft course" do
    scenario "i can view the unpublished partial and rollover" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment_initial_draft], funding_type: "salary"))
      given_there_is_a_next_recruitment_cycle
      when_i_visit_the_course_page
      then_i_should_see_the_description_of_the_initial_draft_course
      and_i_should_see_the_course_button_panel
      and_i_should_see_the_unpublished_partial
      and_i_should_see_the_rollover_button
      when_i_click_the_rollover_button
      then_i_should_see_the_rollover_form_page
      when_i_click_the_rollover_course_button
      then_i_should_see_the_course_show_page_with_success_message
      when_i_click_the_view_rollover_link
      then_i_should_see_the_rolled_over_course_show_page
    end
  end

  describe "rollover with an empty course" do
    scenario "i can see the success message and link" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [], funding_type: "salary"))
      given_there_is_a_next_recruitment_cycle
      when_i_visit_the_rollover_form_page
      when_i_click_the_rollover_course_button
      then_i_should_see_the_course_show_page_with_success_message
      when_i_click_the_view_rollover_link
      then_i_should_see_the_rolled_over_course_show_page
    end
  end

  describe "rollover with an rolled over course" do
    scenario "i can see the success message and link" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment_rolled_over], funding_type: "salary"))
      given_there_is_a_next_recruitment_cycle
      when_i_visit_the_rollover_form_page
      when_i_click_the_rollover_course_button
      then_i_should_see_the_course_show_page_with_success_message
      when_i_click_the_view_rollover_link
      then_i_should_see_the_rolled_over_course_show_page
    end
  end

  describe "with a withdrawn course" do
    scenario "i can view the withdrawn course" do
      given_i_am_authenticated_as_a_provider_user(course: build(:course, enrichments: [course_enrichment_withdrawn]))
      when_i_visit_the_course_page
      then_i_should_see_the_course_button_panel
      and_i_should_see_the_course_withdrawn_date
    end
  end

  def then_i_should_see_the_rolled_over_course_show_page
    expect(page).to have_content "Rolled over"
  end

  def then_i_should_see_the_course_show_page_with_success_message
    expect(page).to have_content "Course rolled over"
  end

  def when_i_click_the_view_rollover_link
    provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
    provider_courses_show_page.rolled_over_course_link.click
  end

  def given_there_is_a_next_recruitment_cycle
    next_year = RecruitmentCycle.current.year.to_i + 1
    RecruitmentCycle.create(year: next_year, application_start_date: Date.new(next_year - 1, 10, 1), application_end_date: Date.new(next_year, 9, 30))
  end

  def when_i_click_the_rollover_course_button
    rollover_form_page.rollover_course_button.click
  end

  def when_i_visit_the_rollover_form_page; end

  def then_i_should_see_the_rollover_form_page
    rollover_form_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}/rollover?")
    expect(page).to have_content "Are you sure you want to roll over the course into the next recruitement cycle?"
  end

  alias_method :when_i_visit_the_rollover_form_page, :then_i_should_see_the_rollover_form_page

  def rollover_form_page
    @rollover_form_page ||= PageObjects::Publish::DraftRollover.new
  end

  def and_i_should_see_the_course_button_panel
    expect(provider_courses_show_page).to have_course_button_panel
  end

  def and_i_should_see_the_rollover_button
    provider_courses_show_page.course_button_panel.within do |course_button_panel|
      expect(course_button_panel).to have_rollover_button
    end
  end

  def and_i_should_not_see_the_rollover_button
    provider_courses_show_page.course_button_panel.within do |course_button_panel|
      expect(course_button_panel).not_to have_rollover_button
    end
  end

  alias_method :then_i_should_see_the_course_button_panel, :and_i_should_see_the_course_button_panel

  def and_i_should_see_the_unpublished_with_changes_partial
    provider_courses_show_page.course_button_panel.within do |course_button_panel|
      expect(course_button_panel).to have_publish_button
      expect(course_button_panel).to have_withdraw_link
      expect(course_button_panel).to have_vacancies_link
      expect(course_button_panel).to have_last_publish_date
    end
  end

  def and_i_should_see_the_unpublished_partial
    provider_courses_show_page.course_button_panel.within do |course_button_panel|
      expect(course_button_panel).to have_publish_button
      expect(course_button_panel).to have_delete_link
    end
  end

  def and_i_should_see_the_published_partial
    provider_courses_show_page.course_button_panel.within do |course_button_panel|
      expect(course_button_panel).to have_view_on_find
      expect(course_button_panel).to have_withdraw_link
      expect(course_button_panel).to have_vacancies_link
      expect(course_button_panel).to have_last_publish_date
    end
  end

  def and_i_click_on_basic_details
    provider_courses_show_page.basic_details_link.click
  end

  def when_i_click_the_rollover_button
    provider_courses_show_page.course_button_panel.rollover_button.click
  end

  def then_i_see_the_course_basic_details
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}/details")
  end

  def and_i_should_see_the_course_withdrawn_date
    provider_courses_show_page.course_button_panel.within do |course_button_panel|
      expect(course_button_panel).to have_withdrawn_date
    end
  end

  def course_enrichment
    @course_enrichment ||= build(:course_enrichment, :published, course_length: :TwoYears, fee_uk_eu: 9250, fee_international: 14000)
  end

  def financial_incentive
    @financial_incentive ||= build(:financial_incentive, bursary_amount: 10000)
  end

  def course_enrichment_unpublished_changes
    @course_enrichment_unpublished_changes ||= build(:course_enrichment, :subsequent_draft, course_length: :TwoYears, fee_uk_eu: 9250, fee_international: 14000)
  end

  def course_enrichment_initial_draft
    @course_enrichment_initial_draft ||= build(:course_enrichment, :initial_draft)
  end

  def course_enrichment_rolled_over
    @course_enrichment_rolled_over ||= build(:course_enrichment, :rolled_over)
  end

  def course_enrichment_withdrawn
    @course_enrichment_withdrawn ||= build(:course_enrichment, :withdrawn)
  end

  def given_i_am_authenticated_as_a_provider_user(course:)
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, sites: [build(:site)], courses: [course]),
        ],
      ),
    )
  end

  def when_i_visit_the_course_page
    provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def then_i_should_see_the_description_of_the_unpublished_changes_course
    expect(provider_courses_show_page.about_course).to have_content(
      course_enrichment_unpublished_changes.about_course,
    )
  end

  def then_i_should_see_the_description_of_the_initial_draft_course
    expect(provider_courses_show_page.about_course).to have_content(
      course_enrichment_initial_draft.about_course,
    )

    expect(provider_courses_show_page.content_status).to have_content(
      "Draft",
    )
  end

  def then_i_should_see_the_description_of_the_fee_course
    expect(provider_courses_show_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )
    expect(provider_courses_show_page.about_course).to have_content(
      course_enrichment.about_course,
    )
    expect(provider_courses_show_page.interview_process).to have_content(
      course_enrichment.interview_process,
    )
    expect(provider_courses_show_page.how_school_placements_work).to have_content(
      course_enrichment.how_school_placements_work,
    )
    expect(provider_courses_show_page.course_length).to have_content(
      "Up to 2 years",
    )
    expect(provider_courses_show_page.fee_uk_eu).to have_content(
      "£9,250",
    )
    expect(provider_courses_show_page.fee_international).to have_content(
      "£14,000",
    )
    expect(provider_courses_show_page.fee_details).to have_content(
      course_enrichment.fee_details,
    )
    expect(provider_courses_show_page.financial_incentives).to have_content(number_to_currency(10000))
    expect(provider_courses_show_page).not_to have_salary_details

    expect(provider_courses_show_page).to have_degree
    expect(provider_courses_show_page).to have_gcse

    expect(provider_courses_show_page.personal_qualities).to have_content(
      course_enrichment.personal_qualities,
    )
    expect(provider_courses_show_page.other_requirements).to have_content(
      course_enrichment.other_requirements,
    )
  end

  def then_i_should_see_the_description_of_the_salary_course
    expect(provider_courses_show_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )

    expect(provider_courses_show_page.content_status).to have_content(
      "Published",
    )

    expect(provider_courses_show_page.about_course).to have_content(
      course_enrichment.about_course,
    )
    expect(provider_courses_show_page.interview_process).to have_content(
      course_enrichment.interview_process,
    )
    expect(provider_courses_show_page.how_school_placements_work).to have_content(
      course_enrichment.how_school_placements_work,
    )
    expect(provider_courses_show_page.course_length).to have_content(
      "Up to 2 years",
    )
    expect(provider_courses_show_page).not_to have_fee_uk_eu

    expect(provider_courses_show_page).not_to have_fee_international

    expect(provider_courses_show_page).not_to have_fee_details
    expect(provider_courses_show_page.salary_details).to have_content(
      course_enrichment.salary_details,
    )
    expect(provider_courses_show_page).to have_degree
    expect(provider_courses_show_page).to have_gcse
    expect(provider_courses_show_page.personal_qualities).to have_content(
      course_enrichment.personal_qualities,
    )
    expect(provider_courses_show_page.other_requirements).to have_content(
      course_enrichment.other_requirements,
    )
  end

  def provider
    @current_user.providers.first
  end

  def course
    provider.courses.first
  end

  def course_with_financial_incentive
    build(
      :course,
      :secondary,
      enrichments: [course_enrichment],
      funding_type: "fee",
      subjects: [build(:secondary_subject, bursary_amount: 10000)],
    )
  end
end
