# frozen_string_literal: true

require "rails_helper"

feature "View allocations" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_are_providers_with_allocations_and_uplifts
    when_i_visit_the_support_allocations_index_page
  end

  scenario "i can view all providers and their allocations" do
    then_i_see_the_providers_and_their_allocations
  end

  def and_there_are_providers_with_allocations_and_uplifts
    @provider = create(:provider)
    @provider2 = create(:provider)
    @allocation = create(:allocation, provider: @provider, number_of_places: 5)
    @allocation2 = create(:allocation, provider: @provider2, number_of_places: 3)
  end

  def when_i_visit_the_support_allocations_index_page
    support_allocations_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def then_i_see_the_providers_and_their_allocations
    expect(support_allocations_index_page.providers.size).to eq(2)
    expect(support_allocations_index_page).to have_content @provider.provider_name
  end
end
