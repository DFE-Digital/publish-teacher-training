# frozen_string_literal: true

require 'rails_helper'

feature 'View pages', :with_publish_constraint do
  scenario 'Environment label and class are read from settings' do
    visit '/cookies'
    expect(page).to have_css('.govuk-phase-banner__content__tag', text: Settings.environment.label)
    expect(page).to have_selector(".app-header--#{Settings.environment.name}")
  end

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
    expect(page).to have_css('h1', text: 'Publish teacher training courses privacy notice')
  end

  scenario 'Navigate to /accessibility' do
    visit '/accessibility'
    expect(page).to have_css('h1', text: 'Accessibility statement for Publish teacher training courses')
  end
end
