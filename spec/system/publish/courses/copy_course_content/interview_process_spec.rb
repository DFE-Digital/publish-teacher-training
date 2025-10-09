# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Copy course content - interview process", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    FeatureFlag.activate(:long_form_content)
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    sign_in_system_test(user:)
  end

  after do
    Timecop.return
    FeatureFlag.deactivate(:long_form_content)
  end

  scenario "Copy financial details content from one course to another", :js do
    given_there_is_two_draft_courses
    when_i_visit_the_target_course_page
    and_i_click_the_change_link

    and_i_choose_a_course_to_copy_content_from
    and_i_click_copy_content
    then_i_see_the_copied_content_in_the_current_course

    and_all_the_copy_course_links_work
  end

  def when_i_visit_the_target_course_page
    visit "/publish/organisations/#{@provider.provider_code}/#{@provider.recruitment_cycle.year}/courses/#{@target_course.course_code}"
    expect(page).to have_content(@target_course.name)
  end

  def and_all_the_copy_course_links_work
    # click_link "Where will the interviews take place?"
    # expect(find_field("Where will the interviews take place? (optional)")).to be_visible
    # scroll_to :top

    click_link "What is the interview process?"
    expect(find_field("What is the interview process? (optional)")).to be_visible
  end

  def and_i_click_the_change_link
    click_link "Change details about the interview process"
  end

  def and_i_choose_a_course_to_copy_content_from
    find_field("Copy from").select @source_course.name_and_code
  end

  def and_i_click_copy_content
    click_button "Copy content"
  end

  def then_i_see_the_copied_content_in_the_current_course
    # expect(find_field("In person", type: :radio, visible: false)).to be_checked
    expect(find_field("What is the interview process? (optional)").value).to eq "Apple"
  end

  def given_there_is_two_draft_courses
    @provider = create(:accredited_provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: 2026))
    @source_course = create(
      :course,
      provider: @provider,
      enrichments: [
        build(
          :course_enrichment,
          :initial_draft,
          :v2,
          interview_location: "both",
          interview_process: "Apple",
        ),
      ],
    )

    @target_course = create(
      :course,
      provider: @provider,
      enrichments: [build(:course_enrichment, :initial_draft, version: 2)],
    )

    user.providers << @provider
  end
end
