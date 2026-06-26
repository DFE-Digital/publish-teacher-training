# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Copy course content - salary fees", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle(2027))
    find_or_create(:recruitment_cycle, year: 2027)
    sign_in_system_test(user:)
  end

  after do
    Timecop.return
  end

  scenario "Copy salary fees content from one course to another" do
    given_there_are_two_salaried_draft_courses
    when_i_visit_the_target_course_page
    and_i_click_the_change_link_for_fees

    and_i_choose_a_course_to_copy_content_from
    and_i_click_copy_content
    then_i_see_the_copied_content_in_the_current_course
  end

  def when_i_visit_the_target_course_page
    visit "/publish/organisations/#{@provider.provider_code}/#{@provider.recruitment_cycle.year}/courses/#{@target_course.course_code}"
    expect(page).to have_content(@target_course.name)
  end

  def and_i_click_the_change_link_for_fees
    click_link "Change fees (optional)"
  end

  def and_i_choose_a_course_to_copy_content_from
    find_field("Copy from").select @source_course.name_and_code
  end

  def and_i_click_copy_content
    click_button "Copy content"
  end

  def then_i_see_the_copied_content_in_the_current_course
    expect(find_field("Give details about any fees or other costs that the trainee might have to pay (optional)").value).to eq "Trainees may need to pay for a DBS check"
  end

  def given_there_are_two_salaried_draft_courses
    @provider = create(:accredited_provider, recruitment_cycle: RecruitmentCycle.current)
    @source_course = create(
      :course,
      :salary_type_based,
      provider: @provider,
      enrichments: [build(:course_enrichment, :initial_draft, salary_fee_details: "Trainees may need to pay for a DBS check")],
    )

    @target_course = create(
      :course,
      :salary_type_based,
      provider: @provider,
      enrichments: [build(:course_enrichment, :initial_draft, version: 2)],
    )

    user.providers << @provider
  end
end
