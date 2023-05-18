# frozen_string_literal: true

require 'rails_helper'

feature 'Accredited provider flow', { can_edit_current_and_next_cycles: false } do
  before do
    allow(Settings.features).to receive(:accredited_provider_search).and_return(true)
    given_i_am_authenticated_as_an_admin_user
    and_there_are_accredited_providers_in_the_database
    and_i_visit_the_index_page
  end

  scenario 'i can view the accredited providers tab when there are none' do
    then_i_see_the_correct_text_for_no_accredited_providers
  end

  scenario 'i can view accredited providers on the index page' do
    and_my_provider_has_accrediting_providers
    and_i_click_on_the_accredited_provider_tab
    then_i_should_see_the_accredited_provider_name_displayed
  end

  scenario 'i can edit accredited providers on the index page' do
    and_my_provider_has_accrediting_providers
    and_i_click_on_the_accredited_provider_tab
    and_i_click_change

    when_i_click_the_back_link
    then_i_return_to_the_index_page
    and_i_click_change

    when_i_input_updated_description
    then_i_should_see_the_updated_description
    and_i_see_the_success_message
  end

  private

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def and_there_are_accredited_providers_in_the_database
    @provider = create(:provider, :lead_school)
    @accredited_provider = create(:provider, :accredited_provider, provider_name: 'UCL', users: [create(:user)])
    @accredited_provider_two = create(:provider, :accredited_provider, provider_name: 'Accredited provider two')
    @accredited_provider_three = create(:provider, :accredited_provider, provider_name: 'Accredited provider three')
  end

  def then_i_return_to_the_index_page
    expect(page).to have_current_path("/support/#{Settings.current_recruitment_cycle_year}/providers/#{@provider.id}/accredited-providers?provider=#{@provider.id}")
  end

  def and_i_visit_the_index_page
    visit support_recruitment_cycle_provider_accredited_providers_path(
      recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      provider_id: @provider.id
    )
  end

  def and_i_click_change
    click_link('Change')
  end

  def when_i_click_the_back_link
    click_on 'Back'
  end

  def and_i_see_the_success_message
    expect(page).to have_content('About the accredited provider updated')
  end

  def then_i_should_see_the_updated_description
    expect(page).to have_text('updates to the AP description')
  end

  def when_i_input_updated_description
    fill_in 'About the accredited provider', with: 'updates to the AP description'
    click_on 'Update description'
  end

  def then_i_see_the_correct_text_for_no_accredited_providers
    expect(page).to have_text("There are no accredited providers for #{@provider.provider_name}")
  end

  def and_i_click_on_the_accredited_provider_tab
    click_link 'Accredited provider'
  end

  def and_my_provider_has_accrediting_providers
    course = build(:course, accrediting_provider: build(:provider, :accredited_provider, provider_name: 'Accrediting provider name'))

    @provider.courses << course
    @provider.update(
      accrediting_provider_enrichments: [{
        'UcasProviderCode' => course.accrediting_provider.provider_code
      }]
    )
  end

  def then_i_should_see_the_accredited_provider_name_displayed
    expect(page).to have_selector('h2', text: 'Accrediting provider name')
  end
end
