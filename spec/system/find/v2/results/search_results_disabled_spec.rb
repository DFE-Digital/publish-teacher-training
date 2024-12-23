# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V2 results - disabled', service: :find do
  before do
    allow(Settings.features).to receive_messages(v2_results: false)
  end

  scenario 'when I visit the results page' do
    when_i_visit_the_find_results_page
    then_i_see_not_found
  end

  def when_i_visit_the_find_results_page
    visit find_v2_results_path
  end

  def then_i_see_not_found
    expect(page.status_code).to eq(404)
  end
end
