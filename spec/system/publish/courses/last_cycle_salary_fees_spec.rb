# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Salary fees last cycle recap", travel: mid_cycle(2026) do
  scenario "editing a next cycle course shows salary content from that course's previous cycle" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_salaried_course_in_the_next_cycle
    and_the_same_course_existed_this_cycle_with_salary_details

    when_i_visit_the_next_cycle_salary_fees_page
    then_i_see_last_cycles_salary_details
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user))
  end

  def and_there_is_a_salaried_course_in_the_next_cycle
    @next_cycle = find_or_create(:recruitment_cycle, :next)
    next_cycle_provider = create(:provider, recruitment_cycle: @next_cycle)
    @course = create(
      :course,
      :salary_type_based,
      provider: next_cycle_provider,
      enrichments: [build(:course_enrichment, :initial_draft, version: 2)],
    )
    @current_user.providers << next_cycle_provider
  end

  def and_the_same_course_existed_this_cycle_with_salary_details
    current_cycle_provider = create(
      :provider,
      recruitment_cycle: RecruitmentCycle.current,
      provider_code: @course.provider.provider_code,
    )
    create(
      :course,
      :salary_type_based,
      provider: current_cycle_provider,
      course_code: @course.course_code,
      enrichments: [build(:course_enrichment, :published, salary_details: "We pay the unqualified teacher salary")],
    )
    @current_user.providers << current_cycle_provider
  end

  def when_i_visit_the_next_cycle_salary_fees_page
    visit salary_fees_publish_provider_recruitment_cycle_course_path(
      @course.provider.provider_code, @next_cycle.year, @course.course_code
    )
  end

  def then_i_see_last_cycles_salary_details
    expect(page).to have_content("See what you wrote last cycle")
    expect(page).to have_content("We pay the unqualified teacher salary")
  end
end
