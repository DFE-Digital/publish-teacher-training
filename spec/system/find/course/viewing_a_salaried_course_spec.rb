# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing a salaried course", service: :find do
  scenario "a course after the 2026 cycle shows the salary fee details", travel: mid_cycle(2027) do
    given_a_salaried_course_exists(salary_fee_details: "Trainees may need to pay for a DBS check")
    when_i_visit_the_course_page
    then_i_see_the_salary_and_financial_support_section
    then_i_see("Trainees may need to pay for a DBS check")
  end

  scenario "a course up to the 2026 cycle shows the salary details", travel: mid_cycle(2026) do
    given_a_salaried_course_exists(salary_details: "We pay the unqualified teacher salary", salary_fee_details: nil)
    when_i_visit_the_course_page
    then_i_see_the_salary_and_financial_support_section
    then_i_see("We pay the unqualified teacher salary")
  end

  def given_a_salaried_course_exists(salary_details: nil, salary_fee_details: nil)
    @course = create(
      :course,
      :salary_type_based,
      :published,
      :open,
      enrichments: [
        build(
          :course_enrichment,
          :published,
          salary_details:,
          salary_fee_details:,
        ),
      ],
    )
  end

  def when_i_visit_the_course_page
    visit find_course_path(@course.provider.provider_code, @course.course_code)
  end

  def then_i_see_the_salary_and_financial_support_section
    expect(page).to have_content("Salary and financial support")
  end

  def then_i_see(content)
    expect(page).to have_content(content)
  end
end
