# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing the financial details row for a salary course" do
  context "when the recruitment cycle is after 2026", travel: mid_cycle(2027) do
    scenario "i see the fees row instead of the salary details row" do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_salaried_course
      when_i_visit_the_course_page
      then_i_see_the_fees_row
      and_i_do_not_see_the_salary_details_row
    end
  end

  context "when the recruitment cycle is 2026 or earlier", travel: mid_cycle(2026) do
    scenario "i see the salary details row instead of the fees row" do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_salaried_course
      when_i_visit_the_course_page
      then_i_see_the_salary_details_row
      and_i_do_not_see_the_fees_row
    end
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_salaried_course
    given_a_course_exists(:salary_type_based, :draft_enrichment)
  end

  def when_i_visit_the_course_page
    visit publish_provider_recruitment_cycle_course_path(
      provider.provider_code, recruitment_cycle_year, course.course_code
    )
  end

  def then_i_see_the_fees_row
    expect(page).to have_content("Fees (optional)")
  end

  def and_i_do_not_see_the_salary_details_row
    expect(page).to have_no_content("Salary details")
  end

  def then_i_see_the_salary_details_row
    expect(page).to have_content("Salary details")
  end

  def and_i_do_not_see_the_fees_row
    expect(page).to have_no_content("Fees (optional)")
  end

  def provider
    @current_user.providers.first
  end

  def recruitment_cycle_year
    provider.recruitment_cycle_year
  end
end
