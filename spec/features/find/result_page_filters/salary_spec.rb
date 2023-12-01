# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Funding filter' do
  include FiltersFeatureSpecsHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario 'Candidate applies salary filter' do
    given_i_have_salaried_and_fee_courses
    when_i_visit_the_find_results_page
    then_i_see_that_the_salary_checkbox_is_not_selected

    when_i_select_the_salary_checkbox
    and_apply_the_filters
    then_i_see_that_the_salary_checkbox_is_selected
    and_the_salary_query_parameter_is_retained
    and_i_should_see_the_salaried_courses
  end

  def given_i_have_salaried_and_fee_courses
    @course_higher_education_programme = create(
      :course,
      :secondary,
      :open,
      site_statuses:,
      program_type: :higher_education_programme
    )
    @course_scitt_salaried_programme = create(
      :course,
      :secondary,
      :open,
      site_statuses:,
      program_type: :scitt_salaried_programme
    )
    @course_higher_education_salaried_programme = create(
      :course,
      :secondary,
      :open,
      site_statuses:,
      program_type: :higher_education_salaried_programme
    )
    @course_school_direct_training_programme = create(
      :course,
      :secondary,
      :open,
      site_statuses:,
      program_type: :school_direct_training_programme
    )
    @course_school_direct_salaried_training_programme = create(
      :course,
      :secondary,
      :open,
      site_statuses:,
      program_type: :school_direct_salaried_training_programme
    )
    @course_scitt_programme = create(
      :course,
      :secondary,
      :open,
      site_statuses:,
      program_type: :scitt_programme
    )
    @course_pg_teaching_apprenticeship = create(
      :course,
      :secondary,
      :open,
      site_statuses:,
      program_type: :pg_teaching_apprenticeship
    )
  end

  def and_i_should_see_the_salaried_courses
    [
      @course_scitt_salaried_programme,
      @course_higher_education_salaried_programme,
      @course_school_direct_salaried_training_programme,
      @course_pg_teaching_apprenticeship
    ].each do |course|
      expect(find_results_page).to have_content(course.decorate.name_and_code)
      expect(find_results_page).to have_content(course.provider.provider_name)
    end
  end

  def then_i_see_that_the_salary_checkbox_is_not_selected
    expect(find_results_page.funding.checkbox).not_to be_checked
  end

  def when_i_select_the_salary_checkbox
    check('Only show courses that come with a salary')
  end

  def then_i_see_that_the_salary_checkbox_is_selected
    expect(find_results_page.funding.checkbox).to be_checked
  end

  def and_the_salary_query_parameter_is_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/results')
      expect(uri.query).to eq('study_type[]=full_time&study_type[]=part_time&qualification[]=qts&qualification[]=pgce_with_qts&qualification[]=pgce+pgde&degree_required=show_all_courses&funding=salary&applications_open=true')
    end
  end

  def site_statuses
    [create(:site_status, :findable)]
  end
end
