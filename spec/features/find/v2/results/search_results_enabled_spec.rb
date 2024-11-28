# frozen_string_literal: true

require 'rails_helper'

feature 'V2 results - enabled' do
  before do
    allow(Settings.features).to receive_messages(v2_results: true)
  end

  scenario 'when I visit the results page' do
    given_i_am_authenticated
    when_i_visit_the_find_results_page
    then_the_page_is_load_successfully
  end

  def given_i_am_authenticated
    page.driver.browser.authorize 'admin', 'password'
  end

  def when_i_visit_the_find_results_page
    visit find_v2_results_path
  end

  def then_the_page_is_load_successfully
    expect(page.status_code).to eq(200)
  end
end
