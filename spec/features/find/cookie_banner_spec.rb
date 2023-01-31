# frozen_string_literal: true

require 'rails_helper'

feature 'cookie banner' do
  before do
    find_results_page.load
  end

  it 'renders a visible js fallback banner' do
    expect(page).to have_text('We use some essential cookies to make this service work.')
  end

  it 'renders a cookie banner' do
    expect(page).to have_button('Accept analytics cookies')
    expect(page).to have_button('Reject analytics cookies')
    expect(page).to have_link('View cookies')
  end

  it 'renders a hidden hide message banner' do
    expect(page).to have_button('Hide this cookies', visible: :hidden)
  end
end
