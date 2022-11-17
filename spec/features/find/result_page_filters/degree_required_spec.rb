require "rails_helper"

RSpec.feature "Degree required filter" do
  include FiltersFeatureSpecsHelper

  scenario 'Candidate applies required degree filters on results page' do
    when_i_visit_the_results_page
    then_i_see_the_two_one_degree_radio_checked

    when_i_select_the_two_two_degree_radio
    and_apply_the_filters
    then_i_see_that_the_two_two_degree_radio_is_selected
    and_the_two_two_degree_query_parameters_are_retained

    when_i_select_the_third_degree_radio
    and_apply_the_filters
    then_i_see_that_the_third_degree_radio_is_selected
    and_the_third_degree_query_parameters_are_retained

    when_i_select_the_pass_degree_radio
    and_apply_the_filters
    then_i_see_that_the_pass_degree_radio_is_selected
    and_the_pass_degree_query_parameters_are_retained
  end

  def then_i_see_the_two_one_degree_radio_checked
    expect(results_page.degree_grade.show_all_courses.checked?).to be(true)
  end

  def when_i_select_the_two_two_degree_radio
    results_page.degree_grade.two_two.choose
  end

  def when_i_select_the_third_degree_radio
    results_page.degree_grade.third_class.choose
  end

  def when_i_select_the_pass_degree_radio
    results_page.degree_grade.not_required.choose
  end

  def then_i_see_that_the_two_two_degree_radio_is_selected
    expect(results_page.degree_grade.two_two).to be_checked
  end

  def then_i_see_that_the_third_degree_radio_is_selected
    expect(results_page.degree_grade.third_class).to be_checked
  end

  def then_i_see_that_the_pass_degree_radio_is_selected
    expect(results_page.degree_grade.not_required).to be_checked
  end

  def and_the_two_two_degree_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/results")
      expect(uri.query).to eq("hasvacancies=true&fulltime=true&parttime=true&qualifications[]=qts&qualifications[]=pgce_with_qts&qualifications[]=other&degree_required=two_two")
    end
  end

  def and_the_third_degree_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/results")
      expect(uri.query).to eq("hasvacancies=true&fulltime=true&parttime=true&qualifications[]=qts&qualifications[]=pgce_with_qts&qualifications[]=other&degree_required=third_class")
    end
  end

  def and_the_pass_degree_query_parameters_are_retained
    URI(current_url).then do |uri|
      expect(uri.path).to eq("/find/results")
      expect(uri.query).to eq("hasvacancies=true&fulltime=true&parttime=true&qualifications[]=qts&qualifications[]=pgce_with_qts&qualifications[]=other&degree_required=not_required")
    end
  end
end