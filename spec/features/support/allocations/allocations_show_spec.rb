# frozen_string_literal: true

require "rails_helper"

feature "View providers" do
  let(:user) { create(:user, :admin) }
  let(:provider) { create(:provider) }
  let(:allocation) { create(:allocation, provider: provider, number_of_places: 5) }

  before do
    given_i_am_authenticated(user: user)
    and_there_are_providers_with_allocations_and_uplifts
    when_i_visit_the_allocations_show_page
  end

  scenario "i can view the providers" do
    then_i_see_the_provider_and_their_allocations
  end

private

  def and_there_are_providers_with_allocations_and_uplifts
    allocation
  end

  def when_i_visit_the_allocations_show_page
    allocations_show_page.load(id: allocation.id)
  end

  def then_i_see_the_provider_and_their_allocations
    expect(allocations_show_page).to have_content provider.provider_name
    expect(allocations_show_page).to have_content "Allocations"
    expect(allocations_show_page).to have_link "Change"
  end
end
