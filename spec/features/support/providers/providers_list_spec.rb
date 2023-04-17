# frozen_string_literal: true

require 'rails_helper'

feature 'View providers' do
  let(:user) { create(:user, :admin) }
  let(:support_new_provider_creation_flow) { false }

  before do
    allow(Settings.features).to receive(:support_new_provider_creation_flow).and_return(support_new_provider_creation_flow)

    given_i_am_authenticated(user:)
    and_there_are_providers
    when_i_visit_the_support_provider_index_page
  end

  scenario 'i can view the providers' do
    then_i_see_the_providers
  end

  scenario 'nagivate to the new provider page' do
    and_i_click_on_add_provider
    then_i_am_on_the_old_new_provider_page
  end

  context 'support_new_provider_creation_flow is set to true' do
    let(:support_new_provider_creation_flow) { true }

    scenario 'nagivate to the old new provider page' do
      and_i_click_on_add_provider
      then_i_am_on_the_new_provider_page
    end
  end

  def and_there_are_providers
    create_list(:provider, 2)
  end

  def when_i_visit_the_support_provider_index_page
    support_provider_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def then_i_see_the_providers
    expect(support_provider_index_page.providers.size).to eq(2)
  end

  def then_i_am_on_the_new_provider_page
    expect(page).to have_current_path("/support/#{Settings.current_recruitment_cycle_year}/providers/onboarding/new")
  end

  def then_i_am_on_the_old_new_provider_page
    expect(page).to have_current_path("/support/#{Settings.current_recruitment_cycle_year}/providers/new")
  end

  def and_i_click_on_add_provider
    click_on('Add provider')
  end
end
