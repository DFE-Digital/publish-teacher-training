# frozen_string_literal: true

require "rails_helper"

feature "Editing course length and fee" do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_course_fee_page
  end

  scenario "i can update some information about the course" do
    and_i_set_information_about_the_course
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_fee_is_updated
  end

  scenario "updating with invalid data" do
    and_i_submit_with_invalid_data
    then_i_should_see_an_error_message
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(:fee_type_based, enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_course_fee_page
    publish_course_fee_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_set_information_about_the_course
    @new_uk_fee = 10_000

    publish_course_fee_page.course_length.upto_two_years.choose
    publish_course_fee_page.uk_fee.set(@new_uk_fee)
  end

  def and_i_submit_with_invalid_data
    publish_course_fee_page.uk_fee.set(120_000)
    and_i_submit
  end

  def and_i_submit
    publish_course_fee_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.saved"))
  end

  def and_the_course_fee_is_updated
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.course_length).to eq("TwoYears")
    expect(enrichment.fee_uk_eu).to eq(@new_uk_fee)
  end

  def then_i_should_see_an_error_message
    expect(publish_course_fee_page.error_messages).to include(
      I18n.t("activemodel.errors.models.publish/course_fee_form.attributes.fee_uk_eu.less_than_or_equal_to"),
    )
  end

  def provider
    @current_user.providers.first
  end
end
