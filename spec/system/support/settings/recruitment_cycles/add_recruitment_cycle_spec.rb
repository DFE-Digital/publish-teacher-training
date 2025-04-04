# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Adding a new recruitment cycle', service: :publish do
  include DfESignInUserHelper
  let(:provider) { create(:provider) }
  let(:user) { create(:user, :admin, providers: [provider]) }

  before do
    Timecop.travel(Time.zone.local(2025, 1, 1))

    driven_by(:rack_test)
    sign_in_system_test(user:)
  end

  scenario 'add a recruitment cycle' do
    visit support_settings_path
    click_link_or_button 'Recruitment Cycles'
    click_link_or_button 'Add recruitment cycle'
    click_link_or_button 'Continue'
    expect(page).to have_text('There is a problem')
    expect(page).to have_text('Enter a year')
    expect(page).to have_text('Enter an application start date')
    expect(page).to have_text('Enter an application end date')

    fill_in 'Recruitment cycle year', with: '2026'
    fill_in 'support_recruitment_cycle_form[application_start_date(3i)]', with: '04'
    fill_in 'support_recruitment_cycle_form[application_start_date(2i)]', with: '10'
    fill_in 'support_recruitment_cycle_form[application_start_date(1i)]', with: '2025'
    fill_in 'support_recruitment_cycle_form[application_end_date(3i)]', with: '04'
    fill_in 'support_recruitment_cycle_form[application_end_date(2i)]', with: '10'
    fill_in 'support_recruitment_cycle_form[application_end_date(1i)]', with: '2026'

    click_link_or_button 'Continue'
    expect(page).to have_text('Recruitment cycle added')
  end
end
