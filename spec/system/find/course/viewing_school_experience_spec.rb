# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing school experience on a course", service: :find do
  scenario "a course after the 2026 cycle that requires school experience shows the row", travel: mid_cycle(2027) do
    given_a_course_exists(
      school_experience_required: true,
      school_experience_required_content: "Spend two weeks in a UK school before applying.",
    )
    when_i_visit_the_course_page
    then_i_see_the_school_experience_row
    then_i_see("Spend two weeks in a UK school before applying.")
  end

  scenario "a course after the 2026 cycle that does not require school experience hides the row", travel: mid_cycle(2027) do
    given_a_course_exists(school_experience_required: false, school_experience_required_content: nil)
    when_i_visit_the_course_page
    then_i_do_not_see_the_school_experience_row
  end

  scenario "a course up to the 2026 cycle does not show the row", travel: mid_cycle(2026) do
    given_a_course_exists(
      school_experience_required: true,
      school_experience_required_content: "Spend two weeks in a UK school before applying.",
    )
    when_i_visit_the_course_page
    then_i_do_not_see_the_school_experience_row
  end

  def given_a_course_exists(school_experience_required:, school_experience_required_content:)
    @course = create(
      :course,
      :salary_type_based,
      :published,
      :open,
      school_experience_required:,
      school_experience_required_content:,
      enrichments: [build(:course_enrichment, :published)],
    )
  end

  def when_i_visit_the_course_page
    visit find_course_path(@course.provider.provider_code, @course.course_code)
  end

  def then_i_see_the_school_experience_row
    expect(page).to have_content("School experience")
    expect(page).to have_content("Previous school experience is required or strongly recommended")
  end

  def then_i_do_not_see_the_school_experience_row
    expect(page).to have_no_content("Previous school experience is required or strongly recommended")
  end

  def then_i_see(content)
    expect(page).to have_content(content)
  end
end
