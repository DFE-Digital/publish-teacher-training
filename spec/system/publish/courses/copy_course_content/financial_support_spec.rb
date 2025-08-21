# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Copy course content - financial support and fees", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    Current.recruitment_cycle = find_or_create(:recruitment_cycle, year: 2026)
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    sign_in_system_test(user:)
  end

  scenario "Copy financial details content from one course to another", :js do
    given_there_is_two_draft_courses
    when_i_visit_the_target_course_page
    and_i_click_the_change_link_for_fees

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
    click_link "Fee for UK citizens"
    expect(find_field("Fee for UK citizens")).to be_visible
    scroll_to :top

    click_link "Fee for non-UK citizens"
    expect(find_field("Fee for non-UK citizens (optional)")).to be_visible
    scroll_to :top

    click_link "When are the fees due?"
    expect(find_field("When are the fees due? Is there a payment schedule? (optional)")).to be_visible
    scroll_to :top

    click_link "Are there any additional fees or costs?"
    expect(find_field("Are there any additional fees or costs? (optional)")).to be_visible
    scroll_to :top

    click_link "Does your organisation offer any financial support?"
    expect(find_field("Does your organisation offer any financial support? (optional)")).to be_visible
  end

  def and_i_click_the_change_link_for_fees
    click_link "Change Fee for UK citizens"
  end

  def and_i_choose_a_course_to_copy_content_from
    find_field("Copy from").select @source_course.name_and_code
  end

  def and_i_click_copy_content
    click_button "Copy content"
  end

  def then_i_see_the_copied_content_in_the_current_course
    expect(find_field("Fee for UK citizens").value).to eq "5"
    expect(find_field("Fee for non-UK citizens (optional)").value).to eq "8"
    expect(find_field("When are the fees due? Is there a payment schedule? (optional)").value).to eq "Apple"
    expect(find_field("Are there any additional fees or costs? (optional)").value).to eq "Orange"
    expect(find_field("Does your organisation offer any financial support? (optional)").value).to eq "Pear"
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
          fee_uk_eu: 5,
          fee_international: 8,
          fee_schedule: "Apple",
          additional_fees: "Orange",
          financial_support: "Pear",
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
