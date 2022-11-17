require "rails_helper"

RSpec.feature "Visa filter" do
  include FiltersFeatureSpecsHelper

  scenario "Candidate applies visa filter" do
    when_i_visit_the_results_page
    then_i_see_that_the_visa_checkbox_is_unchecked

    when_i_select_the_visa_checkbox
    and_apply_the_filters
    then_i_see_that_the_visa_checkbox_is_selected
    and_the_visa_query_parameter_is_retained
  end

  def then_i_see_that_the_visa_checkbox_is_unchecked
    expect(results_page.visa.checkbox).not_to be_checked
  end

  def when_i_select_the_visa_checkbox
    results_page.visa.checkbox.check
  end

  def then_i_see_that_the_visa_checkbox_is_selected
    expect(results_page.visa.checkbox).to be_checked
  end

  def and_the_visa_query_parameter_is_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/results")
      expect(uri.query).to eq("hasvacancies=true&fulltime=true&parttime=true&qualifications[]=qts&qualifications[]=pgce_with_qts&qualifications[]=other&degree_required=show_all_courses&can_sponsor_visa=true")
    end
  end
end
