require "rails_helper"

RSpec.feature "SEND filter" do
  include FiltersFeatureSpecsHelper

  scenario "Candidate applies the SEND filter" do
    when_i_visit_the_results_page
    then_i_see_that_the_send_checkbox_is_not_selected

    when_i_select_the_send_checkbox
    and_apply_the_filters
    then_i_see_that_the_send_checkbox_is_selected
    and_the_send_query_parameter_is_retained
  end

  def then_i_see_that_the_send_checkbox_is_not_selected
    expect(results_page.send.checkbox).not_to be_checked
  end

  def when_i_select_the_send_checkbox
    results_page.send.checkbox.check
  end

  def then_i_see_that_the_send_checkbox_is_selected
    expect(results_page.send.checkbox).to be_checked
  end

  def and_the_send_query_parameter_is_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/results")
      expect(uri.query).to eq("senCourses=true&has_vacancies=true&fulltime=true&parttime=true&qualification[]=qts&qualification[]=pgce_with_qts&qualification[]=other&degree_required=show_all_courses")
    end
  end
end
