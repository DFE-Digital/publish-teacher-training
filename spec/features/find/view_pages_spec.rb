# frozen_string_literal: true

require 'rails_helper'

feature 'View pages' do
  scenario 'Navigate to /cookies' do
    visit '/cookies'
    expect(page).to have_css('h1', text: 'Cookies')
  end

  scenario 'Navigate to /terms-conditions' do
    visit '/terms-conditions'
    expect(page).to have_css('h1', text: 'Terms and conditions')
  end

  scenario 'Navigate to /privacy-policy' do
    visit '/privacy'
    expect(page).to have_css('h1', text: 'Find teacher training courses privacy notice')
  end

  scenario 'Navigate to /accessibility' do
    visit '/accessibility'
    expect(page).to have_css('h1', text: 'Accessibility statement')
    expect(page).to have_text('This statement applies to the Find teacher training courses service (Find)')
  end

  scenario 'Redirect to /cycle-has-ended when cycle open' do
    visit '/cycle-has-ended'
    expect(page).to have_current_path(root_path)
  end
end
