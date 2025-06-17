# frozen_string_literal: true

require "rails_helper"

RSpec.describe "When hide_applications_open_date feature flag is active", service: :find do
  before do
    FeatureFlag.activate(:hide_applications_open_date)
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    when_i_visit_the_results_page
  end

  scenario "when searching for courses with the hide_applications_open_date turned on" do
    then_i_dont_see_the_applications_open_filter_field
  end

  def then_i_dont_see_the_applications_open_filter_field
    expect(page).not_to have_content("Applications open")
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end
end
