# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing course salary fees", travel: mid_cycle(2027) do
  scenario "i can update the salary fees" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_salaried_course_i_want_to_edit
    when_i_visit_the_salary_fees_page
    and_i_fill_in_the_salary_fees
    and_i_submit
    then_i_see_a_success_message
    and_the_salary_fees_are_updated
    and_i_am_on_the_course_details_page
  end

  scenario "i see a validation error when the salary fees exceed the word limit" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_salaried_course_i_want_to_edit
    when_i_visit_the_salary_fees_page
    and_i_fill_in_the_salary_fees_with_too_many_words
    and_i_submit
    then_i_see_a_word_limit_error
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_salaried_course_i_want_to_edit
    given_a_course_exists(:salary_type_based, :draft_enrichment)
  end

  def when_i_visit_the_salary_fees_page
    visit salary_fees_publish_provider_recruitment_cycle_course_path(
      provider.provider_code, recruitment_cycle_year, course.course_code
    )
  end

  def and_i_fill_in_the_salary_fees
    fill_in salary_fees_label, with: "Trainees may need to pay for a DBS check"
  end

  def and_i_fill_in_the_salary_fees_with_too_many_words
    @too_many_words = Faker::Lorem.sentence(word_count: 251)
    fill_in salary_fees_label, with: @too_many_words
  end

  def salary_fees_label
    "Give details about any fees or other costs that the trainee might have to pay (optional)"
  end

  def and_i_submit
    click_on "Update fees"
  end

  def then_i_see_a_success_message
    expect(page).to have_content("Fees updated")
  end

  def and_the_salary_fees_are_updated
    expect(course.enrichments.draft.last.salary_fee_details).to eq("Trainees may need to pay for a DBS check")
  end

  def then_i_see_a_word_limit_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_current_path(
      salary_fees_publish_provider_recruitment_cycle_course_path(
        provider.provider_code, recruitment_cycle_year, course.course_code
      ),
    )
    expect(course.reload.enrichments.draft.last.salary_fee_details).not_to eq(@too_many_words)
  end

  def and_i_am_on_the_course_details_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        provider.provider_code, recruitment_cycle_year, course.course_code
      ),
    )
  end

  def provider
    @current_user.providers.first
  end

  def recruitment_cycle_year
    RecruitmentCycle.current.year
  end
end
