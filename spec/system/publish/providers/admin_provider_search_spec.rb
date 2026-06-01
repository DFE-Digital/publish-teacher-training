# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin provider search autocomplete" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_are_providers
  end

  scenario "an admin finds a provider using the autocomplete", :js do
    when_i_visit_the_organisations_page
    and_i_type_a_provider_name_into_the_search_autocomplete
    then_i_see_the_provider_in_the_autocomplete_suggestions
    when_i_choose_the_provider_from_the_autocomplete_suggestions
    and_i_submit_the_search
    then_i_am_taken_to_the_chosen_provider
  end

private

  def and_there_are_providers
    @provider = create(:provider, provider_name: "Really big school", provider_code: "A01", courses: [build(:course)])
    create_list(:provider, 3)
  end

  def when_i_visit_the_organisations_page
    publish_providers_index_page.load
  end

  def and_i_type_a_provider_name_into_the_search_autocomplete
    fill_in "provider", with: "Really"
  end

  def then_i_see_the_provider_in_the_autocomplete_suggestions
    expect(page).to have_css(autocomplete_listbox_selector, text: @provider.provider_name)
  end

  def when_i_choose_the_provider_from_the_autocomplete_suggestions
    page.find(autocomplete_listbox_selector, text: @provider.provider_name).click
  end

  def and_i_submit_the_search
    publish_providers_index_page.search_button.click
  end

  def then_i_am_taken_to_the_chosen_provider
    expect(page).to have_current_path(%r{/publish/organisations/A01/\d+/courses})
  end

  def autocomplete_listbox_selector
    "#provider__listbox li"
  end
end
