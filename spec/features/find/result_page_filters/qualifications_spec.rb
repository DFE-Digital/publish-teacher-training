require 'rails_helper'

RSpec.feature 'Qualifications filter' do
  include FiltersFeatureSpecsHelper

  scenario 'Candidate applies qualifications filters on results page' do
    when_i_visit_the_results_page
    then_i_see_all_qualifications_checkboxes_are_selected

    when_i_unselect_the_pgce_and_further_education_qualification_checkboxes
    and_apply_the_filters
    then_i_see_that_the_pgce_and_further_education_qualification_checkboxes_are_still_unselected
    and_the_qts_checkbox_is_selected
    and_the_qts_qualification_query_parameters_are_retained
  end

  def then_i_see_all_qualifications_checkboxes_are_selected
    expect(results_page.qualifications.qts).to be_checked
    expect(results_page.qualifications.pgce_with_qts).to be_checked
    expect(results_page.qualifications.other).to be_checked
  end

  def when_i_unselect_the_pgce_and_further_education_qualification_checkboxes
    results_page.qualifications.pgce_with_qts.uncheck
    results_page.qualifications.other.uncheck
  end

  def and_the_qts_checkbox_is_selected
    expect(results_page.qualifications.qts).to be_checked
  end

  def then_i_see_that_the_qts_and_further_education_checkboxes_are_still_unselected
    expect(results_page.qualifications.qts_checkbox).to be_checked
    expect(results_page.qualifications.further_education_checkbox).to be_checked
  end

  def then_i_see_that_the_pgce_and_further_education_qualification_checkboxes_are_still_unselected
    expect(results_page.qualifications.pgce_with_qts).not_to be_checked
    expect(results_page.qualifications.other).not_to be_checked
  end

  def and_the_qts_qualification_query_parameters_are_retained
    expect_page_to_be_displayed_with_query(
      page: results_page,
      expected_query_params: {
        'fulltime' => 'true',
        'parttime' => 'true',
        'hasvacancies' => 'true',
        'degree_required' => 'show_all_courses',
        'qualifications' => %w[QtsOnly],
      },
    )
  end

end