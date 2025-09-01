# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Updating fees and financial support", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    sign_in_system_test(user:)
  end

  context "long form content enabled" do
    before { FeatureFlag.activate(:long_form_content) }

    scenario "A user CANT update fees and financial support page if fees are blank" do
      given_there_is_a_draft_course
      when_i_visit_the_course_page
      and_i_edit_the_fees_and_financial_support_fields(uk_fee: nil, international_fee: nil)

      expect(page).to have_content("Enter fee for UK citizens")
      expect(page).to have_content("Enter fee for non-UK citizens")
    end

    scenario "A user CANT update fees and financial support page if fees above or equal to 100_000" do
      given_there_is_a_draft_course
      when_i_visit_the_course_page
      and_i_edit_the_fees_and_financial_support_fields(uk_fee: 200_000, international_fee: 200_000)

      then_i_see_error_messages_for_course_fees
    end

    scenario "A user CANT update fees and financial support page if optional fields are above the word count" do
      given_there_is_a_draft_course
      when_i_visit_the_course_page
      and_i_edit_the_fees_and_financial_support_fields(
        fee_schedule: generate_text(51),
        additional_fees: generate_text(51),
        financial_support: generate_text(251),
      )

      then_i_see_error_messages_for_fees_content_length
    end

    scenario "update fees and financial support page" do
      given_there_is_a_draft_course
      when_i_visit_the_course_page
      and_i_edit_the_fees_and_financial_support_fields(
        fee_schedule: "Scheduling fees content",
        additional_fees: "Fee additions content",
        financial_support: "Support of financial content",
      )

      then_i_am_redirected_to_the_course_details_page
      and_i_see_a_success_message
      and_all_the_fees_content_is_visible
    end

    scenario "A user CAN see the new long form course content fields if the current cycle is 2026 or beyond" do
      Timecop.travel(Find::CycleTimetable.mid_cycle) do
        given_there_is_a_draft_course
        when_i_visit_the_course_page

        then_the_old_summary_rows_are_visible

        then_change_links_use_new_routes
      end
    end
  end

  context "before longform content" do
    scenario "A user CANT see the new long form course content fields if the current cycle is before 2026" do
      Timecop.travel(Find::CycleTimetable.mid_cycle(2025)) do
        given_there_is_a_draft_course
        when_i_visit_the_course_page

        then_the_summary_rows_are_visible

        and_change_links_use_old_routes
      end
    end
  end

  def then_i_see_error_messages_for_fees_content_length
    expect(page).to have_content("Fee schedule must be 50 words or less")
    expect(page).to have_content("Additional fees must be 50 words or less")
    expect(page).to have_content("Financial support must be 50 words or less")
  end

  def then_i_am_redirected_to_the_course_details_page
    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.start_date.year}/courses/#{@course.course_code}")
  end

  def then_i_see_error_messages_for_course_fees
    expect(page).to have_content("Course fee for UK citizens must be less than or equal to £100,000")
    expect(page).to have_content("Course fee for non-UK citizens must be less than or equal to £100,000")
  end

  def then_the_old_summary_rows_are_visible
    expect(page).to have_content("Fee for UK citizens")
    expect(page).to have_content("Fee for international citizens")
    expect(page).to have_content("Fees and financial support")
  end

  def then_the_summary_rows_are_visible
    expect(page).to have_content("Fee for UK students")
    expect(page).to have_content("Fee for international students")
    expect(page).to have_content("Fees and financial support (optional)")
  end

  def and_all_the_fees_content_is_visible
    within_summary_row("Fees and financial support") do
      expect(page).to have_content("Scheduling fees content\nFee additions content\nSupport of financial content")
    end

    within_summary_row("Fee for UK citizens") do
      expect(page).to have_content("£2,000")
    end

    within_summary_row("Fee for non-UK citizens") do
      expect(page).to have_content("£2,000")
    end
  end

  def when_i_visit_the_course_page
    visit "/publish/organisations/#{@course.provider.provider_code}/#{@course.start_date.year}/courses/#{@course.course_code}"
    expect(page).to have_content(@course.name)
  end

  def and_i_edit_the_fees_and_financial_support_fields(
    uk_fee: 2000,
    international_fee: 2000,
    fee_schedule: "Paragraph 1",
    additional_fees: "Paragraph 2",
    financial_support: "Paragraph 3"
  )
    find_link("Change Fees and financial support").click
    expect(page).to have_content("Fees and financial support")

    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/fees-and-financial-support")

    fill_in "Fee for UK citizens", with: uk_fee
    fill_in "Fee for non-UK citizens", with: international_fee

    fill_in "When are the fees due? Is there a payment schedule? (optional)", with: fee_schedule
    fill_in "Are there any additional fees or costs? (optional)", with: additional_fees
    fill_in "Does your organisation offer any financial support? (optional)", with: financial_support

    click_link_or_button "Update fees and financial support"
  end

  def given_there_is_a_draft_course
    provider_in_cycle = create(:provider)
    user.providers << provider_in_cycle

    course_enrichment = build(:course_enrichment, :initial_draft, course_length: :TwoYears)

    @course = create(
      :course,
      :with_accrediting_provider,
      :with_gcse_equivalency,
      :can_sponsor_student_visa,
      provider: provider_in_cycle,
      accrediting_provider: build(:accredited_provider),
      enrichments: [course_enrichment],
      sites: [create(:site, location_name: "location 1")],
      study_sites: [create(:site, :study_site)],
    )
  end

  def and_change_links_use_old_routes
    page.find_link("Change fees and financial support").click
    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fees-and-financial-support")
  end

  def then_change_links_use_new_routes
    page.find_link("Change Fees and financial support").click
    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/fees-and-financial-support")
  end

  def generate_text(word_count)
    "#{Faker::Lorem.words(number: word_count).join(' ').capitalize}."
  end

  def and_i_see_a_success_message
    within(".govuk-notification-banner") do
      expect(page).to have_content("Success\nFees and financial support updated")
    end
  end
end
