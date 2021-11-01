# frozen_string_literal: true

require "rails_helper"

feature "View providers" do
  let(:user) { create(:user, :admin) }
  let(:provider) { create(:provider) }
  let(:provider2) { create(:provider) }
  let(:allocation) { create(:allocation, provider: provider, number_of_places: 5) }
  let(:allocation2) { create(:allocation, provider: provider2, number_of_places: 3) }

  before do
    given_i_am_authenticated(user: user)
    and_there_are_providers_with_allocations_and_uplifts
    when_i_visit_the_allocations_index_page
  end

  scenario "i can view the providers" do
    then_i_see_the_providers_and_their_allocations
  end

  def and_there_are_providers_with_allocations_and_uplifts
    allocation
    allocation2
  end

  def when_i_visit_the_allocations_index_page
    allocations_index_page.load
  end

  def then_i_see_the_providers_and_their_allocations
    expect(allocations_index_page.providers.size).to eq(2)
    expect(allocations_index_page).to have_content provider.provider_name
  end
end
